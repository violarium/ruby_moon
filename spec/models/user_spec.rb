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


  describe '#save_web_subscription' do
    let(:user) { FactoryGirl.create(:user) }

    it 'creates new subscription note for user' do
      expect do
        user.save_web_subscription(endpoint: '123', keys: {p256dh: '1', auth: '2'})
      end.to change { UserWebSubscription.count }.by(1)
      user.reload

      subscription = user.user_web_subscriptions.first
      expect(subscription.endpoint).to eq '123'
      expect(subscription.p256dh).to eq '1'
      expect(subscription.auth).to eq '2'
    end

    it 'updated existing subscription' do
      user.user_web_subscriptions.create!(endpoint: '123')

      expect do
        user.save_web_subscription(endpoint: '123', keys: {p256dh: 'foo', auth: 'bar'})
      end.not_to change { UserWebSubscription.count }
      user.reload

      subscription = user.user_web_subscriptions.first
      expect(subscription.endpoint).to eq '123'
      expect(subscription.p256dh).to eq 'foo'
      expect(subscription.auth).to eq 'bar'
    end

    it 'keeps only up to 5 new subscriptions' do
      Timecop.freeze(Time.new(2015, 1, 1)) do
        user.save_web_subscription(endpoint: '1', keys: {p256dh: '1', auth: '2'})
      end
      Timecop.freeze(Time.new(2015, 1, 2)) do
        user.save_web_subscription(endpoint: '2', keys: {p256dh: '1', auth: '2'})
        user.save_web_subscription(endpoint: '3', keys: {p256dh: '1', auth: '2'})
        user.save_web_subscription(endpoint: '4', keys: {p256dh: '1', auth: '2'})
        user.save_web_subscription(endpoint: '5', keys: {p256dh: '1', auth: '2'})
      end
      expect(user.user_web_subscriptions.count).to eq 5

      Timecop.freeze(Time.new(2015, 1, 3)) do
        user.save_web_subscription(endpoint: '6', keys: {p256dh: '1', auth: '2'})
      end
      expect(user.user_web_subscriptions.count).to eq 5

      endpoints = []
      user.user_web_subscriptions.all.each do |s|
        endpoints.push(s.endpoint)
      end
      expect(endpoints).not_to include('1')
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

    it 'deletes user token for user' do
      user.user_tokens.create!(token: 'hello 1')
      user.user_tokens.create!(token: 'hello 2')
      expect { user.delete }.to change { UserToken.count }.by(-2)
    end

    it 'deletes user regular days' do
      user.regular_days.create!(date: Date.new(2015, 1, 2))
      user.regular_days.create!(date: Date.new(2015, 1, 3))
      expect { user.delete }.to change { RegularDay.count }.by(-2)
    end

    it 'deletes user subscriptions' do
      user.user_web_subscriptions.create!(endpoint: '1')
      user.user_web_subscriptions.create!(endpoint: '2')
      expect { user.delete }.to change { UserWebSubscription.count }.by(-2)
    end
  end
end