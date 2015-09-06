require 'rails_helper'

describe UserCalendarFacade do

  let(:user) { FactoryGirl.create(:user) }
  let(:calendar_data_provider) { UserCalendarFacade.new(user) }

  describe '#month_info' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
      user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1))
      user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))

      user.future_critical_periods.create!(from: Date.new(2015, 2, 1), to: Date.new(2015, 2, 2))
      user.future_critical_periods.create!(from: Date.new(2016, 1, 10), to: Date.new(2016, 1, 15))
    end

    it 'should have correct dates in month_data' do
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:month][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
    end

    it 'should have correct month date in month_data' do
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:month][:month_date]).to eq(Date.new(2015, 1))
    end

    it 'should have critical dates in critical_dates' do
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:critical_dates]).to eq([Date.new(2015, 1, 31), Date.new(2015, 2, 1), Date.new(2015, 2, 2)])
    end

    it 'should have future critical dates in future_critical_dates' do
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:future_critical_dates]).to eq([Date.new(2015, 2, 1), Date.new(2015, 2, 2)])
    end

    it 'should have received current date' do
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:current_date]).to eq Date.new(2015, 2, 3)
    end

    it 'should have upcoming critical period' do
      expect(user).to receive(:upcoming_critical_period).with(Date.new(2015, 2, 3)).and_return('upcoming period')
      @result = calendar_data_provider.month_info(Date.new(2015, 1), Date.new(2015, 2, 3))
      expect(@result[:upcoming_period]).to eq 'upcoming period'
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