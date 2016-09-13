require 'rails_helper'

describe CriticalPeriod do
  it_behaves_like 'a user period'


  describe 'critical days validation' do
    let(:user) { FactoryGirl.create(:user) }
    let(:period) { user.critical_periods.build(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 12)) }

    it 'should not be valid when critical days are out of range' do
      period.critical_days.build(date: Date.new(2015, 1, 15))
      expect(period).not_to be_valid
    end

    it 'should be valid when critical days within range' do
      period.critical_days.build(date: Date.new(2015, 1, 11))
      expect(period).to be_valid
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


  describe '#critical_day_by_date' do
    let(:user) { FactoryGirl.create(:user) }
    let(:period) { user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 12)) }

    it 'should return critical day for received date if there are one' do
      critical_day = period.critical_days.create!(date: Date.new(2015, 1, 11))
      expect(period.critical_day_by_date(Date.new(2015, 1, 11))).to eq critical_day
    end

    it 'should return nil for received date if there are not critical day' do
      period.critical_days.create!(date: Date.new(2015, 1, 11))
      expect(period.critical_day_by_date(Date.new(2015, 1, 12))).to be_nil
    end
  end


  describe '#cleanup_critical_days' do
    let(:user) { FactoryGirl.create(:user) }
    let(:period) { user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 12)) }

    it 'should cleanup critical days which are out of range' do
      period.critical_days.build(date: Date.new(2015, 1, 11))
      period.critical_days.build(date: Date.new(2015, 1, 13))
      period.cleanup_critical_days
      period.save!
      period.reload

      expect(period.critical_days.length).to eq 1
      expect(period.critical_days[0].date).to eq Date.new(2015, 1, 11)
    end

    it 'should leave same number of critical days if nothing has changed' do
      period.critical_days.build(date: Date.new(2015, 1, 11))
      period.critical_days.build(date: Date.new(2015, 1, 12))
      period.cleanup_critical_days
      period.save!
      period.reload

      expect(period.critical_days.length).to eq 2
    end

    it 'should leave only one critical day for each date if there are many somehow' do
      period.critical_days.build(date: Date.new(2015, 1, 11))
      period.critical_days.build(date: Date.new(2015, 1, 11))
      period.cleanup_critical_days
      period.save!
      period.reload

      expect(period.critical_days.length).to eq 1
    end
  end
end