require 'rails_helper'

describe CriticalPeriod do
  let(:user) { FactoryGirl.create(:user) }

  shared_examples 'a scope to select period which includes received date' do
    it 'should make query to select period which includes date' do
      date = period.from + 1.day
      raise ArgumentError.new('Period date from and date to should be different') if date == period.to

      selected_period = CriticalPeriod.near_by_date(period.from + 1.day).first
      expect(selected_period).to eq(period)
    end

    it 'should make query to select period which from date equals to date' do
      selected_period = CriticalPeriod.near_by_date(period.from).first
      expect(selected_period).to eq(period)
    end

    it 'should make query to select period which to date equals to date' do
      selected_period = CriticalPeriod.near_by_date(period.to).first
      expect(selected_period).to eq(period)
    end
  end

  describe '.has_date' do
    it_behaves_like 'a scope to select period which includes received date' do
      let(:period) { user.critical_periods.create!(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10)) }
    end
  end

  describe '.near_by_date' do
    let!(:periods) do
      [user.critical_periods.create!(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 20)),
       user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 20))]
    end

    describe 'when date not in period' do
      it 'should make query to select closest critical period after date' do
        expect(CriticalPeriod.near_by_date(Date.new(2015, 1, 3)).first).to eq(periods[1])
      end

      it 'should make query not to select critical period after date which is too far' do
        expect(CriticalPeriod.near_by_date(Date.new(2015, 1, 2)).first).to be_nil
      end

      it 'should make query to select closest critical period before date' do
        expect(CriticalPeriod.near_by_date(Date.new(2015, 2, 27)).first).to eq(periods[0])
      end

      it 'should make query not to select critical period before date which is too far' do
        expect(CriticalPeriod.near_by_date(Date.new(2015, 1, 28)).first).to be_nil
      end
    end

    it_behaves_like 'a scope to select period which includes received date' do
      let(:period) { periods[1] }
    end
  end

  describe '.between_dates' do
    let!(:periods) do
      [user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2)),
       user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1)),
       user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))]
    end

    it 'should return periods overlapped by date borders' do
      collection = CriticalPeriod.between_dates(Date.new(2015, 1, 29), Date.new(2015, 3, 5)).all.to_a
      expect(collection). to eq [periods[0], periods[1]]
    end

    it 'should return periods which overlap date borders' do
      collection = CriticalPeriod.between_dates(Date.new(2016, 1, 2), Date.new(2016, 1, 4)).all.to_a
      expect(collection). to eq [periods[2]]
    end

    it 'should return periods which have from border' do
      collection = CriticalPeriod.between_dates(Date.new(2015, 2, 1), Date.new(2015, 3, 5)).all.to_a
      expect(collection). to eq [periods[0], periods[1]]
    end

    it 'should return periods which have to border' do
      collection = CriticalPeriod.between_dates(Date.new(2015, 1, 29), Date.new(2015, 2, 1)).all.to_a
      expect(collection). to eq [periods[0]]
    end
  end

  describe 'validation' do
    let(:critical_period) { user.critical_periods.new(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10)) }

    it 'should be valid with correct data' do
      expect(critical_period).to be_valid
    end

    it 'should not be valid without "from" date' do
      critical_period.from = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid without "to" date' do
      critical_period.from = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid without user' do
      critical_period.user = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid when "from" date is greater than "to" date' do
      critical_period.to = critical_period.from - 1.day
      expect(critical_period).not_to be_valid
    end

    describe 'margin validation' do
      describe 'margin before' do
        it 'should not be valid if there are no enough space' do
          user.critical_periods.create!(from: Date.new(2014, 12, 25), to: Date.new(2014, 12, 29))
          expect(critical_period).not_to be_valid
        end

        it 'should be valid if there are enough space' do
          user.critical_periods.create!(from: Date.new(2014, 12, 25), to: Date.new(2014, 12, 28))
          expect(critical_period).to be_valid
        end
      end

      describe 'margin after' do
        it 'should not be valid if there are no enough space' do
          user.critical_periods.create!(from: Date.new(2015, 1, 17), to: Date.new(2015, 1, 20))
          expect(critical_period).not_to be_valid
        end

        it 'should be valid if there are enough space' do
          user.critical_periods.create!(from: Date.new(2015, 1, 18), to: Date.new(2015, 1, 20))
          expect(critical_period).to be_valid
        end
      end
    end


    describe 'intersection validation' do

      it 'should not be valid when current period matches another one' do
        critical_period.dup.save!
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when current period overlaps another one' do
        user.critical_periods.create!(from: critical_period.from + 1.day, to: critical_period.to - 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when current period within anther one' do
        user.critical_periods.create!(from: critical_period.from - 1.day, to: critical_period.to + 1.day)
        expect(critical_period).not_to be_valid
      end


      it 'should not be valid when "from" date within another period' do
        user.critical_periods.create!(from: critical_period.from - 1.day, to: critical_period.from + 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when "from" date equals to "to" date in another period' do
        user.critical_periods.create!(from: critical_period.from - 10.days, to: critical_period.from)
        expect(critical_period).not_to be_valid
      end


      it 'should not be valid when current period "to" date within another period' do
        user.critical_periods.create!(from: critical_period.to - 1.day, to: critical_period.to + 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when "to" date equals to "from" date in another period' do
        user.critical_periods.create!(from: critical_period.to, to: critical_period.to + 10.days)
        expect(critical_period).not_to be_valid
      end


      it 'should be valid when we edit current period' do
        critical_period.save!
        expect(critical_period).to be_valid
      end

      it 'should be valid when periods belong to different users' do
        another_user = FactoryGirl.create(:user, email: 'another@email.com')
        another_period = critical_period.dup
        another_period.user = another_user
        another_period.save!
        expect(critical_period).to be_valid
      end
    end
  end


  describe '#append_date' do
    let!(:period) { CriticalPeriod.new(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 12)) }

    it 'should append correctly date before' do
      period.append_date(Date.new(2015, 1, 8))
      expect(period.from).to eq Date.new(2015, 1, 8)
      expect(period.to).to eq Date.new(2015, 1, 12)
    end

    it 'should append correctly date after' do
      period.append_date(Date.new(2015, 1, 14))
      expect(period.from).to eq Date.new(2015, 1, 10)
      expect(period.to).to eq Date.new(2015, 1, 14)
    end

    it 'should not change period if date inside of it' do
      period.append_date(Date.new(2015, 1, 11))
      expect(period.from).to eq Date.new(2015, 1, 10)
      expect(period.to).to eq Date.new(2015, 1, 12)
    end
  end
end