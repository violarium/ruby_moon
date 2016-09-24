require 'rails_helper'

describe RegularDay do
  describe '#love' do
    it 'should be unknown by default' do
      expect(RegularDay.new.love).to eq RegularDay::LOVE_UNKNOWN
    end
  end


  describe '#notes' do
    it 'should be empty string by default' do
      expect(RegularDay.new.notes).to eq ''
    end
  end


  describe 'validation' do
    let(:user) { FactoryGirl.create(:user) }
    let(:day) { user.regular_days.build(date: Date.new(2016, 9, 15)) }

    it 'should be valid' do
      expect(day).to be_valid
    end

    it 'should not be valid without specified date' do
      day.date = nil
      expect(day).not_to be_valid
    end

    it 'should not be valid without specified user' do
      day.user = nil
      expect(day).not_to be_valid
    end

    it 'should not be valid if there are another regular day with same date for user' do
      day.dup.save!
      expect(day).not_to be_valid
    end

    it 'should be valid if there are date for different user' do
      another = FactoryGirl.create(:user, email: 'another@example.org')
      another.regular_days.create!(date: day.date)
      expect(day).to be_valid
    end

    it 'should be valid on correct love values' do
      [RegularDay::LOVE_UNKNOWN, RegularDay::LOVE_UNPROTECTED, RegularDay::LOVE_PROTECTED].each do |love_value|
        day.love = love_value
        expect(day).to be_valid
      end
    end

    it 'should not be valid on incorrect love values' do
      [nil, 'wron'].each do |love_value|
        day.love = love_value
        expect(day).not_to be_valid
      end
    end
  end
end