require 'rails_helper'

describe CalendarHelper do
  describe '#month_with_year' do
    it 'should print out month with year correctly' do
      expect(month_with_year(Date.new(2015, 2))).to eq 'February, 2015'
    end
  end
end