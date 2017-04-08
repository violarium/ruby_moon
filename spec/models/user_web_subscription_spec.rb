require 'rails_helper'

describe UserWebSubscription do
  describe 'endpoint' do
    it 'is required' do
      subscription = UserWebSubscription.new(endpoint: nil)
      expect(subscription).not_to be_valid
    end

    it 'should be unique' do
      UserWebSubscription.create!(endpoint: 'endpoint')
      subscription = UserWebSubscription.new(endpoint: 'endpoint')

      expect(subscription).not_to be_valid
    end
  end

  describe '.save_subscription' do
    let(:user) { FactoryGirl.create(:user) }

    it 'creates new subscription note for user' do
      expect do
        UserWebSubscription.save_subscription(user, endpoint: '123', keys: {p256dh: '1', auth: '2'})
      end.to change { UserWebSubscription.count }.by(1)

      subscription = user.reload.user_web_subscriptions.first
      expect(subscription.endpoint).to eq '123'
      expect(subscription.p256dh).to eq '1'
      expect(subscription.auth).to eq '2'
    end

    it 'updated existing subscription' do
      user.user_web_subscriptions.create!(endpoint: '123')

      expect do
        UserWebSubscription.save_subscription(user, endpoint: '123', keys: {p256dh: 'foo', auth: 'bar'})
      end.not_to(change { UserWebSubscription.count })

      subscription = user.reload.user_web_subscriptions.first
      expect(subscription.endpoint).to eq '123'
      expect(subscription.p256dh).to eq 'foo'
      expect(subscription.auth).to eq 'bar'
    end

    it 'remove same subscription from different user' do
      user.user_web_subscriptions.create!(endpoint: '123')

      another_user = FactoryGirl.create(:user, email: 'another@email.com')
      UserWebSubscription.save_subscription(another_user, endpoint: '123', keys: {p256dh: '1', auth: '2'})

      expect(user.reload.user_web_subscriptions.first).to be_nil

      subscription = another_user.reload.user_web_subscriptions.first
      expect(subscription.endpoint).to eq '123'
    end
  end


  describe '.clean_up_for_user' do
    let(:user) { FactoryGirl.create(:user) }

    it 'keeps only up to 5 new subscriptions' do
      Timecop.freeze(Time.new(2015, 1, 1)) do
        user.user_web_subscriptions.create!(endpoint: '1', p256dh: '1', auth: '2')
      end
      Timecop.freeze(Time.new(2015, 1, 2)) do
        user.user_web_subscriptions.create!(endpoint: '2', p256dh: '1', auth: '2')
        user.user_web_subscriptions.create!(endpoint: '3', p256dh: '1', auth: '2')
        user.user_web_subscriptions.create!(endpoint: '4', p256dh: '1', auth: '2')
        user.user_web_subscriptions.create!(endpoint: '5', p256dh: '1', auth: '2')
      end
      Timecop.freeze(Time.new(2015, 1, 3)) do
        user.user_web_subscriptions.create!(endpoint: '6', p256dh: '1', auth: '2')
      end


      UserWebSubscription.clean_up_for_user(user)

      user.reload
      expect(user.user_web_subscriptions.count).to eq 5

      endpoints = []
      user.user_web_subscriptions.all.each do |s|
        endpoints.push(s.endpoint)
      end
      expect(endpoints).not_to include('1')
    end
  end
end