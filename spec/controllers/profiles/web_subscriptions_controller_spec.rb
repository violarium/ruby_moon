require 'rails_helper'

describe Profiles::WebSubscriptionsController do
  describe 'POST #create' do
    include_examples 'controller sign in required' do
      before { post :create }
    end
  end

  describe 'when user signed in' do
    it 'should save subscription for user' do
      user = controller_sign_in
      subscription_data = {endpoint: 'endpoint', keys: {auth: 'auth', p256dh: 'p256dh'}}
      expect(user).to receive(:save_web_subscription).with(subscription_data)
      post :create, subscription: subscription_data
    end
  end
end