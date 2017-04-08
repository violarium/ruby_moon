class UserWebSubscription
  # Max count of web subscriptions per user
  MAX_WEB_SUBSCRIPTIONS = 5

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :endpoint, type: String
  field :auth, type: String
  field :p256dh, type: String

  index({ user_id: 1 })
  index({ endpoint: 1 }, { unique: true })

  validates :endpoint, presence: true, uniqueness: true


  # Save subscription for user
  #
  # @param user [User]
  # @param subscription_input [Hash]
  def self.save_subscription(user, subscription_input)
    subscription_data = { endpoint: subscription_input[:endpoint] }
    if subscription_input[:keys]
      subscription_data[:p256dh] = subscription_input[:keys][:p256dh]
      subscription_data[:auth] = subscription_input[:keys][:auth]
    end

    # Find and update or create
    subscription = self.where(endpoint: subscription_data[:endpoint]).first
    subscription = self.new if subscription.nil?
    subscription.user = user
    subscription.attributes = subscription_data
    subscription.save
  end


  # Clean up subscriptions for user
  #
  # @param user [User]
  def self.clean_up_for_user(user)
    if user.user_web_subscriptions.count > MAX_WEB_SUBSCRIPTIONS
      user.user_web_subscriptions.order_by(:created_at => 'desc', :updated_at => 'desc').all.each_with_index do |s, i|
        s.delete if i >= MAX_WEB_SUBSCRIPTIONS
      end
    end
  end
end