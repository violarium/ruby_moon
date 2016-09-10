require 'rails_helper'

describe UserCalendarFacade do

  let(:user) { FactoryGirl.create(:user) }
  let(:calendar_data_provider) { UserCalendarFacade.new(user) }


  describe '#month_info' do
    it 'should have received current date' do
      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(result[:current_date]).to eq Date.new(2015, 2, 3)
    end


    it 'should have month date' do
      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(result[:month_date]).to eq Date.new(2015, 1, 1)
    end


    it 'should return array of dates' do
      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(result[:dates][0][:date]).to eq Date.new(2014, 12, 29)
      expect(result[:dates][-1][:date]).to eq Date.new(2015, 2, 8)
    end


    it 'should have info if each date is critical' do
      user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
      user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1))
      user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))
      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))

      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 1, 29) }.first[:is_critical]).to be_falsey
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 1, 31) }.first[:is_critical]).to be_truthy
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 1) }.first[:is_critical]).to be_truthy
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 2) }.first[:is_critical]).to be_truthy
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 8) }.first[:is_critical]).to be_falsey
    end


    it 'should have info if each date is predicted critical' do
      user.future_critical_periods.create!(from: Date.new(2015, 2, 1), to: Date.new(2015, 2, 2))
      user.future_critical_periods.create!(from: Date.new(2016, 1, 10), to: Date.new(2016, 1, 15))
      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))

      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 1, 29) }.first[:is_future_critical]).to be_falsey
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 1) }.first[:is_future_critical]).to be_truthy
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 2) }.first[:is_future_critical]).to be_truthy
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 8) }.first[:is_future_critical]).to be_falsey
    end


    it 'should have upcoming critical period' do
      future_periods = [
        user.future_critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 15)),
        user.future_critical_periods.create!(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 12)),
      ]

      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(result[:upcoming_period]).to eq future_periods[1]
    end


    it 'should have critical day values for dates' do
      critical_periods = [
        user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2)),
        user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1)),
      ]
      critical_periods[0].critical_days.create!(date: Date.new(2015, 1, 31), value: 'large')
      critical_periods[0].critical_days.create!(date: Date.new(2015, 2, 2), value: 'unknown')

      result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))

      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 1, 31) }.first[:critical_day_value]).to eq 'large'
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 1) }.first[:critical_day_value]).to be_nil
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 2) }.first[:critical_day_value]).to eq 'unknown'
      expect(result[:dates].select { |d| d[:date] == Date.new(2015, 2, 8) }.first[:critical_day_value]).to be_nil
    end
  end


  describe '#day_info' do
    it 'should return correct date by params' do
      result = calendar_data_provider.day_info(Date.new(2015, 2, 2))
      expect(result[:date]).to eq(Date.new(2015, 2, 2))
    end

    describe 'current period' do
      it 'should return period, if date inside of it' do
        period = user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
        result = calendar_data_provider.day_info(Date.new(2015, 2, 2))
        expect(result[:current_period]).to eq(period)
      end

      it 'should return nil if it not inside of period' do
        result = calendar_data_provider.day_info(Date.new(2015, 2, 2))
        expect(result[:current_period]).to be_nil
      end
    end

    describe 'close_periods' do
      it 'should return empty array, if there are no close periods' do
        result = calendar_data_provider.day_info(Date.new(2015, 2, 2))
        expect(result[:close_periods]).to eq []
      end

      it 'should return array with close period if there are one' do
        period = user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 1))
        result = calendar_data_provider.day_info(Date.new(2015, 2, 2))
        expect(result[:close_periods]).to eq [period]
      end

      it 'should return all close periods' do
        period1 = user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 1))
        period2 = user.critical_periods.create!(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 11))
        result = calendar_data_provider.day_info(Date.new(2015, 2, 5))
        expect(result[:close_periods]).to eq [period1, period2]
      end
    end
  end
end