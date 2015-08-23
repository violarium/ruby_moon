require 'rails_helper'

describe CriticalPeriod do
  it_behaves_like 'a user period'


  describe '#append_date' do
    let!(:period) { CriticalPeriod.new(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 12)) }

    it 'should append correctly date before' do
      period.append_date(Date.new(2015, 1, 8))
      expect(period.from).to eq Date.new(2015, 1, 8)
      expect(period.to).to eq Date.new(2015, 1, 12)
    end

    it 'should append correctly date after' do
      period.append_date(Date.new(2015, 1, 14))
      expect(period.from).to eq Date.new(2015, 1, 10)
      expect(period.to).to eq Date.new(2015, 1, 14)
    end

    it 'should not change period if date inside of it' do
      period.append_date(Date.new(2015, 1, 11))
      expect(period.from).to eq Date.new(2015, 1, 10)
      expect(period.to).to eq Date.new(2015, 1, 12)
    end
  end
end