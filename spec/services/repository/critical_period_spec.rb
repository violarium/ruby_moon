require 'rails_helper'

describe Repository::CriticalPeriod do
  describe 'self#date_collection' do
    let(:user) { FactoryGirl.create(:user) }

    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2))
      user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1))
      user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))
    end

    it 'should return correct array of dates when date borders overlap periods' do
      collection = Repository::CriticalPeriod.date_collection(user, Date.new(2015, 1, 29), Date.new(2015, 3, 5))
      expect(collection). to eq [Date.new(2015, 1, 31), Date.new(2015, 2, 1), Date.new(2015, 2, 2),
                                 Date.new(2015, 2, 28), Date.new(2015, 3, 1)]
    end

    it 'should return correct array of dates when date borders within period' do
      collection = Repository::CriticalPeriod.date_collection(user, Date.new(2016, 1, 2), Date.new(2016, 1, 4))
      expect(collection). to eq [Date.new(2016, 1, 2), Date.new(2016, 1, 3), Date.new(2016, 1, 4)]
    end

    it 'should return correct array of dates when from border inside of period' do
      collection = Repository::CriticalPeriod.date_collection(user, Date.new(2015, 2, 1), Date.new(2015, 3, 5))
      expect(collection). to eq [Date.new(2015, 2, 1), Date.new(2015, 2, 2),
                                 Date.new(2015, 2, 28), Date.new(2015, 3, 1)]
    end

    it 'should return correct array of dates when to border inside of period' do
      collection = Repository::CriticalPeriod.date_collection(user, Date.new(2015, 1, 29), Date.new(2015, 2, 1))
      expect(collection). to eq [Date.new(2015, 1, 31), Date.new(2015, 2, 1)]
    end
  end
end