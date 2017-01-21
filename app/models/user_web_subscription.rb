class UserWebSubscription
  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :endpoint, type: String
  field :auth, type: String
  field :p256dh, type: String

  index({ user_id: 1 })
  index({ endpoint: 1 }, { unique: true })

  validates :endpoint, presence: true, uniqueness: true
end