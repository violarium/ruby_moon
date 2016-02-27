class UserToken
  # Lifetime for each token in days.
  LIFETIME_DAYS = 90

  include Mongoid::Document
  include Mongoid::Timestamps

  belongs_to :user

  field :encrypted_token, type: String
  field :expires_at, type: Time

  index({ encrypted_token: 1 }, { unique: true })

  validates :encrypted_token, presence: true, uniqueness: true


  # Set token.
  # Token will be converted to special hash object.
  # This hash object also will be written into encrypted token.
  def token=(token)
    self.encrypted_token = ::Digest::SHA2.hexdigest(token)
  end


  # Prolong expires time.
  def prolong
    self.expires_at = Time.now + LIFETIME_DAYS.days
  end


  # Scope to select note with token.
  scope :with_token, -> (token) do
    where(encrypted_token: ::Digest::SHA2.hexdigest(token))
  end


  # Scope to select not expired tokens.
  scope :not_expired, -> do
    where(:expires_at.gte => Time.now)
  end


  # Delete all the expired tokens.
  def self.delete_expired
    where(:expires_at.lt => Time.now).all.each do |token|
      token.delete
    end
  end


  before_save do |document|
    document.prolong if document.expires_at.nil?
  end
end