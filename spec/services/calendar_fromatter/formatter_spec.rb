require 'rails_helper'

describe CalendarFormatter::Formatter do
  let(:formatter) { CalendarFormatter::Formatter.new }

  describe '#mont_list' do

    describe ':date_from and :date_to' do
      it 'should return correct date_from and date_to by default (for 1 amount)' do
        result = formatter.month_list(Date.new(2015, 1))
        expect(result[:date_from]).to eq(Date.new(2014, 12, 29))
        expect(result[:date_to]).to eq(Date.new(2015, 2, 8))
      end

      it 'should return correct date_from and date_to for 2 months' do
        result = formatter.month_list(Date.new(2015, 1), amount: 2)
        expect(result[:date_from]).to eq(Date.new(2014, 12, 29))
        expect(result[:date_to]).to eq(Date.new(2015, 3, 8))
      end

      it 'should return correct date_from and date_to for 3 months' do
        result = formatter.month_list(Date.new(2015, 1), amount: 3)
        expect(result[:date_from]).to eq(Date.new(2014, 12, 29))
        expect(result[:date_to]).to eq(Date.new(2015, 4, 5))
      end
    end

    describe ':month_list array' do
      it 'should have correct length for each amount of month' do
        (1 .. 3).each do |amount|
          result = formatter.month_list(Date.new(2015, 1), amount: amount)
          expect(result[:month_list].length).to eq amount
        end
      end

      describe ':dates in array' do
        it 'should return correct date array by default (for 1 amount)' do
          result = formatter.month_list(Date.new(2015, 1))
          expect(result[:month_list][0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
        end

        it 'should return correct date array for 2 month' do
          result = formatter.month_list(Date.new(2015, 1), amount: 2)
          expect(result[:month_list][0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
          expect(result[:month_list][1][:dates]).to eq (Date.new(2015, 1, 26) .. Date.new(2015, 3, 8))
        end

        it 'should return correct date array for 3 month' do
          result = formatter.month_list(Date.new(2015, 1), amount: 3)
          expect(result[:month_list][0][:dates]).to eq (Date.new(2014, 12, 29) .. Date.new(2015, 2, 8))
          expect(result[:month_list][1][:dates]).to eq (Date.new(2015, 1, 26) .. Date.new(2015, 3, 8))
          expect(result[:month_list][2][:dates]).to eq (Date.new(2015, 2, 23) .. Date.new(2015, 4, 5))
        end
      end

      describe ':week in array' do
        it 'should return correct week sequence for each month' do
          result = formatter.month_list(Date.new(2015, 1), amount: 3)
          week_sequence = [:monday, :tuesday, :wednesday, :thursday, :friday, :saturday, :sunday]

          expect(result[:month_list][0][:week]).to eq week_sequence
          expect(result[:month_list][1][:week]).to eq week_sequence
          expect(result[:month_list][2][:week]).to eq week_sequence
        end
      end

      describe ':first_date in array' do
        it 'should return correct first_date by default (for 1 amount)' do
          result = formatter.month_list(Date.new(2015, 1))
          expect(result[:month_list][0][:first_date]).to eq Date.new(2015, 1)
        end

        it 'should return correct first_date for 2 months' do
          result = formatter.month_list(Date.new(2015, 1), amount: 2)
          expect(result[:month_list][0][:first_date]).to eq Date.new(2015, 1)
          expect(result[:month_list][1][:first_date]).to eq Date.new(2015, 2)
        end

        it 'should return correct first_date for 3 months' do
          result = formatter.month_list(Date.new(2015, 1), amount: 3)
          expect(result[:month_list][0][:first_date]).to eq Date.new(2015, 1)
          expect(result[:month_list][1][:first_date]).to eq Date.new(2015, 2)
          expect(result[:month_list][2][:first_date]).to eq Date.new(2015, 3)
        end
      end
    end
  end
end