require 'rails_helper'

describe CalendarHelper do
  describe '#month_date_title' do
    it 'should print out month with year correctly' do
      expect(month_date_title(Date.new(2015, 2))).to eq 'February, 2015'
    end
  end

  describe '#full_date_title' do
    it 'should print out day with month and year correctly' do
      expect(full_date_title(Date.new(2015, 2, 10))).to eq '10 February, 2015'
    end
  end
end