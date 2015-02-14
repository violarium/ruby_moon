require 'rails_helper'

describe Calendar::CalendarFormatter do
  let(:formatter) { Calendar::CalendarFormatter.new }

  describe '#mont_list' do
    it 'should have correct length for each limit of month' do
      (1 .. 3).each do |limit|
        result = formatter.month_list(Date.new(2015, 1), limit: limit)
        expect(result.length).to eq limit
      end
    end

    describe ':dates in array' do
      it 'should return correct date array by default (for 1 amount)' do
        result = formatter.month_list(Date.new(2015, 1))
        expect(result[0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
      end

      it 'should return correct date array for 2 month' do
        result = formatter.month_list(Date.new(2015, 1), limit: 2)
        expect(result[0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
        expect(result[1][:dates]).to eq (Date.new(2015, 1, 26) .. Date.new(2015, 3, 8))
      end

      it 'should return correct date array for 3 month' do
        result = formatter.month_list(Date.new(2015, 1), limit: 3)
        expect(result[0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
        expect(result[1][:dates]).to eq (Date.new(2015, 1, 26) .. Date.new(2015, 3, 8))
        expect(result[2][:dates]).to eq (Date.new(2015, 2, 23) .. Date.new(2015, 4, 5))
      end
    end

    describe ':week_days in array' do
      it 'should return correct week sequence for each month' do
        result = formatter.month_list(Date.new(2015, 1), limit: 3)
        week_sequence = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

        expect(result[0][:week_days]).to eq week_sequence
        expect(result[1][:week_days]).to eq week_sequence
        expect(result[2][:week_days]).to eq week_sequence
      end
    end

    describe ':month_date in array' do
      it 'should return correct month date by default (for 1 amount)' do
        result = formatter.month_list(Date.new(2015, 1))
        expect(result[0][:month_date]).to eq Date.new(2015, 1)
      end

      it 'should return correct month date for 2 months' do
        result = formatter.month_list(Date.new(2015, 1), limit: 2)
        expect(result[0][:month_date]).to eq Date.new(2015, 1)
        expect(result[1][:month_date]).to eq Date.new(2015, 2)
      end

      it 'should return correct month date for 3 months' do
        result = formatter.month_list(Date.new(2015, 1), limit: 3)
        expect(result[0][:month_date]).to eq Date.new(2015, 1)
        expect(result[1][:month_date]).to eq Date.new(2015, 2)
        expect(result[2][:month_date]).to eq Date.new(2015, 3)
      end
    end
  end
end