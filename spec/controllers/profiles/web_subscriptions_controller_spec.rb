require 'rails_helper'

describe Profiles::WebSubscriptionsController do
  describe 'POST #create' do
    include_examples 'controller sign in required' do
      before { post :create }
    end
  end

  describe 'when user signed in' do
    before { @user = controller_sign_in }

    it 'should update user web_subscription with input params' do
      subscription_data = {'endpoint' => 'endpoint', 'keys' => {'auth' => 'auth', 'p256dh' => 'p256dh'}}
      post :create, subscription: subscription_data
      expect(@user.reload.web_subscription).to eq subscription_data
    end
  end
end