require 'rails_helper'

describe CriticalDay do
  describe '#value' do
    it 'should have value :unknown by default' do
      expect(CriticalDay.new.value).to eq :unknown
    end
  end

  describe 'validation' do
    let(:user) { FactoryGirl.create(:user) }
    let(:period) { user.critical_periods.build(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 2)) }
    let(:critical_day) { period.critical_days.build(date: Date.new(2015, 1, 1)) }

    it 'should be valid' do
      expect(critical_day).to be_valid
    end

    it 'should not be valid without period' do
      critical_day.critical_period = nil
      expect(critical_day).not_to be_valid
    end

    it 'should not be valid without date specified' do
      critical_day.date = nil
      expect(critical_day).not_to be_valid
    end

    it 'should not be valid without specified value' do
      critical_day.value = nil
      expect(critical_day).not_to be_valid
    end

    it 'should be valid with correct value' do
      [:unknown, :small, :medium, :large].each do |value|
        critical_day.value = value
        expect(critical_day).to be_valid
      end
    end

    it 'should not be valid with wrong value' do
      critical_day.value = -1
      expect(critical_day).not_to be_valid
    end
  end
end