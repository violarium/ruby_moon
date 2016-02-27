require 'rails_helper'

describe User do
  describe 'password hashing' do

    it 'should encrypt the password' do
      expect(::BCrypt::Password).to receive(:create).with('password').and_return('encrypted password')
      user = User.create(password: 'password')
      expect(user.encrypted_password).to eq 'encrypted password'
    end

    it 'should compare encrypted password with actual correctly' do
      user = User.create(password: 'password')
      expect(user.password == 'password').to eq true
    end

    it 'should work correctly when corrupt encrypted password is stored' do
      user = User.create(encrypted_password: 'bad')
      expect(user.password).to be_nil
    end
  end


  describe '#upcoming_critical_period' do
    let(:user) { FactoryGirl.create(:user) }

    let!(:future_periods) do
      [user.future_critical_periods.create!(from: Date.new(2015, 1, 31), to: Date.new(2015, 2, 2)),
       user.future_critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 1)),
       user.future_critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))]
    end

    it 'should return closest critical period after received date' do
      result = user.upcoming_critical_period(Date.new(2015, 2, 10))
      expect(result).to eq future_periods[1]
    end

    it 'should not return critical period if it started' do
      result = user.upcoming_critical_period(Date.new(2015, 2, 28))
      expect(result).to eq future_periods[2]
    end

    it 'should return null if there are no incoming periods' do
      result = user.upcoming_critical_period(Date.new(2016, 1, 6))
      expect(result).to be_nil
    end
  end


  describe '#in_time_zone' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should return received time in user timezone' do
      time = Time.now
      expect(user.in_time_zone(time).zone).to eq time.in_time_zone('Moscow').zone
    end
  end


  describe '#create_token' do
    let(:user) { FactoryGirl.create(:user) }

    it 'generates token and return not encrypted string' do
      token_string = user.create_token
      expect(user.user_tokens.with_token(token_string).first).not_to be_nil
    end
  end


  describe 'validation' do
    let(:user) { User.new(email: 'example@email.com', password: '123456', password_confirmation: '123456', time_zone: 'Moscow') }

    it 'should be valid with correct data' do
      expect(user).to be_valid
    end

    describe 'email' do
      it 'should be required' do
        user.email = ''
        expect(user).not_to be_valid
      end

      it 'should have correct format' do
        user.email = 'test'
        expect(user).not_to be_valid
      end

      it 'should be unique' do
        another_user = user.dup
        another_user.save!
        expect(user).not_to be_valid
      end

      it 'should be unique in any case' do
        another_user = user.dup
        another_user.email.upcase
        another_user.save!
        expect(user).not_to be_valid
      end
    end

    describe 'password' do
      it 'should be required' do
        user.password = ''
        user.password_confirmation = ''
        expect(user).not_to be_valid
      end
    end

    describe 'password confirmation' do
      it 'should match password' do
        user.password_confirmation = '123'
        expect(user).not_to be_valid
      end
    end

    describe 'timezone' do
      it 'should be valid with correct timezone' do
        user.time_zone = 'Moscow'
        expect(user).to be_valid
      end

      it 'should not be valid with incorrect timezone' do
        user.time_zone = 'hello'
        expect(user).not_to be_valid
      end
    end

    describe 'notify_at' do
      it 'should be required' do
        user.notify_at = nil
        expect(user).not_to be_valid
      end

      it 'should be value between 0 and 23' do
        [0, 14, 23].each do |val|
          user.notify_at = val
          expect(user).to be_valid
        end

        [-1, 24].each do |val|
          user.notify_at = val
          expect(user).not_to be_valid
        end
      end
    end

    describe 'notify_before' do
      it 'should be valid when it is empty array' do
        user.notify_before = []
        expect(user).to be_valid
      end

      it 'should be valid with 0, 1, 2' do
        user.notify_before = [0, 1, 2]
        expect(user).to be_valid

        [0, 1, 2].each do |val|
          user.notify_before = [val]
          expect(user).to be_valid
        end
      end

      it 'should not be valid with incorrect cariant' do
        user.notify_before = [0, 1, 7]
        expect(user).not_to be_valid
      end

      it 'should not be valid with not unique values' do
        user.notify_before = [0, 0, 1]
        expect(user).not_to be_valid
      end
    end

    describe 'locale' do
      it 'should be valid for allowed locales' do
        User::ALLOWED_LOCALES.keys.each do |locale|
          user.locale = locale
          expect(user).to be_valid
        end
      end

      it 'should not be valid without locale' do
        user.locale = nil
        expect(user).not_to be_valid
      end

      it 'should not be valid with wrong locale' do
        user.locale = :pirate
        expect(user).not_to be_valid
      end
    end
  end

  describe 'user deletion' do
    let(:user) { FactoryGirl.create(:user) }

    it 'deletes critical periods for user' do
      user.critical_periods.create!(from: Time.new(2015, 1, 1), to: Time.new(2015, 1, 2))
      expect { user.delete }.to change { CriticalPeriod.count }.from(1).to(0)
    end

    it 'deletes future critical periods for user' do
      user.future_critical_periods.create!(from: Time.new(2015, 1, 1), to: Time.new(2015, 1, 2))
      expect { user.delete }.to change { FutureCriticalPeriod.count }.from(1).to(0)
    end
  end
end