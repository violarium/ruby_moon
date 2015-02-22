require 'rails_helper'

describe CriticalPeriod do

  describe 'validation' do
    let(:user) { User.create!(email: 'email@example.net') }
    let(:critical_period) { user.critical_periods.new(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10)) }

    it 'should be valid with correct data' do
      expect(critical_period).to be_valid
    end

    it 'should not be valid without "from" date' do
      critical_period.from = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid without "to" date' do
      critical_period.from = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid without user' do
      critical_period.user = nil
      expect(critical_period).not_to be_valid
    end

    it 'should not be valid when "from" date is greater than "to" date' do
      critical_period.to = critical_period.from - 1.day
      expect(critical_period).not_to be_valid
    end


    describe 'intersection validation' do

      it 'should not be valid when current period matches another one' do
        critical_period.dup.save!
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when current period overlaps another one' do
        user.critical_periods.create!(from: critical_period.from + 1.day, to: critical_period.to - 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when current period within anther one' do
        user.critical_periods.create!(from: critical_period.from - 1.day, to: critical_period.to + 1.day)
        expect(critical_period).not_to be_valid
      end


      it 'should not be valid when "from" date within another period' do
        user.critical_periods.create!(from: critical_period.from - 1.day, to: critical_period.from + 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when "from" date equals to "to" date in another period' do
        user.critical_periods.create!(from: critical_period.from - 10.days, to: critical_period.from)
        expect(critical_period).not_to be_valid
      end


      it 'should not be valid when current period "to" date within another period' do
        user.critical_periods.create!(from: critical_period.to - 1.day, to: critical_period.to + 1.day)
        expect(critical_period).not_to be_valid
      end

      it 'should not be valid when "to" date equals to "from" date in another period' do
        user.critical_periods.create!(from: critical_period.to, to: critical_period.to + 10.days)
        expect(critical_period).not_to be_valid
      end


      it 'should be valid when we edit current period' do
        critical_period.save!
        expect(critical_period).to be_valid
      end

      it 'should be valid when periods belong to different users' do
        another_user = User.create!(email: 'another@email.com')
        another_period = critical_period.dup
        another_period.user = another_user
        another_period.save!
        expect(critical_period).to be_valid
      end
    end
  end
end