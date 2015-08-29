require 'rails_helper'

describe DataProvider::UserCalendar do

  let(:user) { FactoryGirl.create(:user) }
  let(:calendar_data_provider) { DataProvider::UserCalendar.new(user) }

  describe '#month_grid_data' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
      user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1))
      user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))

      user.future_critical_periods.create!(from: Date.new(2015, 2, 1), to: Date.new(2015, 2, 2))
      user.future_critical_periods.create!(from: Date.new(2016, 1, 10), to: Date.new(2016, 1, 15))

      @result = calendar_data_provider.month_grid_data(Date.new(2015, 1))
    end

    it 'should have correct dates in month_data' do
      expect(@result[:month][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
    end

    it 'should have correct month date in month_data' do
      expect(@result[:month][:month_date]).to eq(Date.new(2015, 1))
    end

    it 'should have critical dates in critical_dates' do
      expect(@result[:critical_dates]).to eq([Date.new(2015, 1, 31), Date.new(2015, 2, 1), Date.new(2015, 2, 2)])
    end

    it 'should have future critical dates in future_critical_dates' do
      expect(@result[:future_critical_dates]).to eq([Date.new(2015, 2, 1), Date.new(2015, 2, 2)])
    end
  end
end