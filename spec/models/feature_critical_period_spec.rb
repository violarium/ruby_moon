require 'rails_helper'

describe FutureCriticalPeriod do
  it_behaves_like 'a user period'

  describe '#upcoming' do
    let(:user) { FactoryGirl.create(:user) }

    let!(:future_periods) do
      [user.future_critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2)),
       user.future_critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1)),
       user.future_critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))]
    end

    it 'should return closest critical period after received date' do
      result = FutureCriticalPeriod.upcoming(Date.new(2015, 2, 10)).first
      expect(result).to eq future_periods[1]
    end

    it 'should not return critical period if it started' do
      result = FutureCriticalPeriod.upcoming(Date.new(2015, 2, 28)).first
      expect(result).to eq future_periods[2]
    end

    it 'should return null if there are no incoming periods' do
      result = FutureCriticalPeriod.upcoming(Date.new(2016, 1, 6)).first
      expect(result).to be_nil
    end
  end
end
