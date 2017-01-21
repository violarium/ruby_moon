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
end