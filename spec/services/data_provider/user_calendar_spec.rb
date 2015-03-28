require 'rails_helper'

describe DataProvider::UserCalendar do

  describe 'integration' do
    let(:user) { FactoryGirl.create(:user) }
    let(:calendar_data_provider) { DataProvider::UserCalendar.new(user) }

    describe '#month_grid_data' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
        user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1))
        user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))

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
    end
  end


  describe 'unit' do
    let(:user) { User.new }
    let(:calendar_data_provider) { DataProvider::UserCalendar.new(user) }

    describe '#month_grid_data' do
      it 'should get month list from calendar formatter' do
        calendar_formatter = double('calendar_formatter')
        expect(Calendar::CalendarFormatter).to receive(:new).and_return(calendar_formatter)
        month = {dates: [Date.new(2015, 1, 1), Date.new(2015, 1, 2)]}
        expect(calendar_formatter).to receive(:month).with(Date.new(2015, 9)).and_return(month)

        result = calendar_data_provider.month_grid_data(Date.new(2015, 9))
        expect(result[:month]).to eq(month)
      end

      it 'should get critical dates from critical period repository' do
        calendar_formatter = double('calendar_formatter')
        expect(Calendar::CalendarFormatter).to receive(:new).and_return(calendar_formatter)
        expect(calendar_formatter).to receive(:month).and_return({dates: [1, 2, 3]})

        expect(Repository::CriticalPeriod).to receive(:date_collection).with(user, 1, 3).and_return('date collection')
        result = calendar_data_provider.month_grid_data(Date.new(2015, 1))
        expect(result[:critical_dates]).to eq('date collection')
      end
    end
  end
end