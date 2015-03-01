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

        @result = calendar_data_provider.month_grid_data(Date.new(2015, 1), limit: 3, current_date: Date.new(2015, 1, 5))
      end

      it 'should have correct dates in month_list' do
        expect(@result[:month_list][0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
        expect(@result[:month_list][1][:dates]).to eq (Date.new(2015, 1, 26) .. Date.new(2015, 3, 8))
        expect(@result[:month_list][2][:dates]).to eq (Date.new(2015, 2, 23) .. Date.new(2015, 4, 5))
      end

      it 'should have critical dates in critical_dates' do
        expect(@result[:critical_dates]).to eq([Date.new(2015, 1, 31), Date.new(2015, 2, 1),
                                              Date.new(2015, 2, 2), Date.new(2015, 2, 28),
                                              Date.new(2015, 3, 1)])
      end

      it 'should have received date in current_date' do
        expect(@result[:current_date]).to eq(Date.new(2015, 1, 5))
      end

      it 'should have correct month date in month_date' do
        expect(@result[:month_date]).to eq(Date.new(2015, 1))
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
        month_list = [{dates: []}, {dates: []}]
        expect(calendar_formatter).to receive(:month_list).with(Date.new(2015, 1), limit: 3).and_return(month_list)

        result = calendar_data_provider.month_grid_data(Date.new(2015, 1), limit: 3)
        expect(result[:month_list]).to eq(month_list)
      end

      it 'should get critical dates from critical period repository' do
        calendar_formatter = double('calendar_formatter')
        expect(Calendar::CalendarFormatter).to receive(:new).and_return(calendar_formatter)
        expect(calendar_formatter).to receive(:month_list).and_return([{dates: [1, 2, 3]},
                                                                       {dates: [4, 5, 6]}])

        expect(Repository::CriticalPeriod).to receive(:date_collection).with(user, 1, 6).and_return('date collection')
        result = calendar_data_provider.month_grid_data(Date.new(2015, 1), limit: 2)
        expect(result[:critical_dates]).to eq('date collection')
      end
    end
  end
end