require 'rails_helper'

describe CalendarDayForm do
  let(:user) { FactoryGirl.create(:user) }

  describe '#is_critical' do
    it 'should be false by default' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.is_critical).to eq false
    end

    it 'should be true is there are critical period in this day' do
      user.critical_periods.create(from: Date.new(2015, 1, 6), to: Date.new(2015, 1, 8))
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.is_critical).to eq true
    end

    it 'should be true when we pass "on"' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      form.is_critical = 'on'
      expect(form.is_critical).to eq true
    end

    it 'should be false when we pass "off"' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      form.is_critical = 'off'
      expect(form.is_critical).to eq false
    end
  end

  describe '#delete_way' do
    it 'should be valid on values: head, tail, entirely' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      %w(head tail entirely).each do |value|
        form.delete_way = value
        expect(form).to be_valid
      end
    end

    it 'should be invalid on wrong values' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      form.delete_way = 'wrong'
      expect(form).not_to be_valid
    end
  end

  describe '#critical_day_value' do
    it 'should have value "unknown by" default' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.critical_day_value).to eq CriticalDay::VALUE_UNKNOWN
    end

    it 'should be invalid with wrong values' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      [nil, 'wrong'].each do |value|
        form.critical_day_value = value
        expect(form).not_to be_valid
      end
    end

    it 'should be valid with correct values' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      %w(unknown small medium large).each do |value|
        form.critical_day_value = value
        expect(form).to be_valid
      end
    end

    it 'should have same value as the critical day on this date' do
      period = user.critical_periods.create(from: Date.new(2015, 1, 6), to: Date.new(2015, 1, 8))
      period.critical_days.build(date: Date.new(2015, 1, 7), value: CriticalDay::VALUE_MEDIUM)
      period.save!
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.critical_day_value).to eq CriticalDay::VALUE_MEDIUM
    end
  end


  describe '#love' do
    it 'should have value "unknown by" default' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.love).to eq RegularDay::LOVE_UNKNOWN
    end

    it 'should be valid with correct values' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      [nil, 'wrong'].each do |value|
        form.love = value
        expect(form).not_to be_valid
      end
    end

    it 'should not be valid with incorrect values' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      [RegularDay::LOVE_UNKNOWN, RegularDay::LOVE_PROTECTED, RegularDay::LOVE_UNPROTECTED].each do |value|
        form.love = value
        expect(form).to be_valid
      end
    end

    it 'should has love as the regular day love on this date' do
      user.regular_days.create!(date: Date.new(2015, 1, 7), love: RegularDay::LOVE_UNPROTECTED)
      user.reload
      form = CalendarDayForm.new(user, Date.new(2015, 1, 7))
      expect(form.love).to eq RegularDay::LOVE_UNPROTECTED
    end
  end


  describe 'creating new critical period' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7), {is_critical: true}) }

    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should create new period' do
      form.submit
      critical_period = user.critical_periods.first
      expect(critical_period.from).to eq(Date.new(2015, 1, 7))
      expect(critical_period.to).to eq(Date.new(2015, 1, 7))
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end
  end


  describe 'not creating new period' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7)) }

    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should not create new period' do
      expect { form.submit }.not_to change { user.critical_periods.count }
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end
  end


  describe 'extending critical period' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 9), {is_critical: true}) }
    before do
      user.critical_periods.create(from: Date.new(2015, 1, 6), to: Date.new(2015, 1, 7))
      user.reload
    end

    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should extend existing period' do
      form.submit
      critical_period = user.critical_periods.first
      expect(critical_period.from).to eq(Date.new(2015, 1, 6))
      expect(critical_period.to).to eq(Date.new(2015, 1, 9))
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end
  end


  describe 'deleting critical period' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10))
      user.reload
    end

    describe 'when we want to delete a tail' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7),
                                       {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_TAIL}) }

      it 'should be valid' do
        expect(form).to be_valid
      end

      it 'should delete tail on submit' do
        form.submit
        critical_period = user.critical_periods.first
        expect(critical_period.from).to eq(Date.new(2015, 1, 5))
        expect(critical_period.to).to eq(Date.new(2015, 1, 6))
      end

      it 'should return true on submit' do
        expect(form.submit).to eq true
      end
    end

    describe 'when we want to delete a tail when we point on the head' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 5),
                                       {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_TAIL}) }

      it 'should be valid' do
        expect(form).to be_valid
      end

      it 'should delete whole period on submit' do
        expect { form.submit }.to change { user.critical_periods.count }.by(-1)
      end

      it 'should return true on submit' do
        expect(form.submit).to eq true
      end
    end

    describe 'when we want to delete a head' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7),
                                       {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_HEAD}) }

      it 'should be valid' do
        expect(form).to be_valid
      end

      it 'should delete head on submit' do
        form.submit
        critical_period = user.critical_periods.first
        expect(critical_period.from).to eq(Date.new(2015, 1, 8))
        expect(critical_period.to).to eq(Date.new(2015, 1, 10))
      end

      it 'should return true on submit' do
        expect(form.submit).to eq true
      end
    end

    describe 'when we want to delete a head when we point on the tail' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 10),
                                       {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_HEAD}) }

      it 'should be valid' do
        expect(form).to be_valid
      end

      it 'should delete whole period on submit' do
        expect { form.submit }.to change { user.critical_periods.count }.by(-1)
      end

      it 'should return true on submit' do
        expect(form.submit).to eq true
      end
    end

    describe 'when we want to delete period entirely' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 10),
                                       {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_ENTIRELY}) }

      it 'should be valid' do
        expect(form).to be_valid
      end

      it 'should delete period entirely on submit' do
        expect { form.submit }.to change { user.critical_periods.count }.by(-1)
      end

      it 'should return true on submit' do
        expect(form.submit).to eq true
      end
    end
  end


  describe 'when we try to add or extend period which is can not feet between others' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10))
      user.critical_periods.create!(from: Date.new(2015, 1, 20), to: Date.new(2015, 1, 25))
      user.reload
    end

    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 15), {is_critical: true}) }

    it 'should not be valid' do
      expect(form).not_to be_valid
    end

    it 'should do nothing on submit' do
      expect { form.submit }.not_to change { user.critical_periods.count }
      periods = user.critical_periods

      expect(periods[0].from).to eq Date.new(2015, 1, 5)
      expect(periods[0].to).to eq Date.new(2015, 1, 10)

      expect(periods[1].from).to eq Date.new(2015, 1, 20)
      expect(periods[1].to).to eq Date.new(2015, 1, 25)
    end

    it 'should return false on submit' do
      expect(form.submit).to eq false
    end
  end


  describe 'set critical value for new period' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7),
                                     {is_critical: true, critical_day_value: CriticalDay::VALUE_MEDIUM}) }

    it 'should ve valid' do
      expect(form).to be_valid
    end

    it 'should create critical day with value which we need' do
      form.submit

      critical_period = user.critical_periods.first
      critical_day = critical_period.critical_days.to_a[0]

      expect(critical_day.date).to eq Date.new(2015, 1, 7)
      expect(critical_day.value).to eq CriticalDay::VALUE_MEDIUM
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end
  end

  describe 'set critical value for existing period' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7),
                                     {is_critical: true, critical_day_value: CriticalDay::VALUE_LARGE}) }
    before do
      period = user.critical_periods.create(from: Date.new(2015, 1, 6), to: Date.new(2015, 1, 8))
      period.critical_days.create(date: Date.new(2015, 1, 7), value: CriticalDay::VALUE_SMALL)
      user.reload
    end

    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should update critical day with value which wee need' do
      form.submit

      critical_period = user.critical_periods.first
      critical_day = critical_period.critical_days[0]

      expect(critical_day.date).to eq Date.new(2015, 1, 7)
      expect(critical_day.value).to eq CriticalDay::VALUE_LARGE
    end

    it 'should return true on submit' do
      expect(form.submit).to eq true
    end
  end

  describe 'cut critical period with critical day values' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7), {is_critical: false, delete_way: CalendarDayForm::DELETE_WAY_TAIL}) }
    before do
      period = user.critical_periods.create(from: Date.new(2015, 1, 6), to: Date.new(2015, 1, 8))
      period.critical_days.create(date: Date.new(2015, 1, 6), value: CriticalDay::VALUE_SMALL)
      period.critical_days.create(date: Date.new(2015, 1, 7), value: CriticalDay::VALUE_SMALL)
      user.reload
    end

    it 'should be valid' do
      expect(form).to be_valid
    end

    it 'should delete critical days out of range' do
      form.submit
      period = user.critical_periods.first
      expect(period.critical_days.length).to eq 1
      expect(period.critical_days[0][:date]).to eq Date.new(2015, 1, 6)
    end
  end


  describe 'set love' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7), {love: RegularDay::LOVE_UNPROTECTED}) }

    it 'should set love value and create regular day with it' do
      form.submit
      regular_day = user.regular_days.first
      expect(regular_day.date).to eq(Date.new(2015, 1, 7))
      expect(regular_day.love).to eq(RegularDay::LOVE_UNPROTECTED)
    end

    it 'should chan\ge love value for existing regular day' do
      regular_day = user.regular_days.create!(date: Date.new(2015, 1, 7), love: RegularDay::LOVE_PROTECTED)
      form.submit
      regular_day.reload
      expect(regular_day.date).to eq(Date.new(2015, 1, 7))
      expect(regular_day.love).to eq(RegularDay::LOVE_UNPROTECTED)
    end
  end
end