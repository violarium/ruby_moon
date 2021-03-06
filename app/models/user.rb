# Class for user model.
#
# Fields:
#   email - user email.
#   password and password_confirmation - fields for password, encrypted_password - encrypted value.
#   time_zone - current user timezone from ActiveSupport::TimeZone.
#   notify_before - days in which notifications should be sent, 0 means in day of event, 1 - in day before event.
#   notify_at - hour to send notification about event (see #notify_before).
#
# Associations:
#   critical_periods
#   future_critical_periods
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include PasswordsConcern

  # Allowed values for #notify_before.
  ALLOWED_NOTIFY_BEFORE = [0, 1, 2]

  # Allowed locales for #locale and system ar all
  ALLOWED_LOCALES = { en: 'English', ru: 'Русский' }

  # Max count of web subscriptions
  MAX_WEB_SUBSCRIPTIONS = 5

  field :email, type: String
  field :encrypted_password, type: String
  field :time_zone, type: String, default: 'UTC'
  field :notify_before, type: Array, default: ALLOWED_NOTIFY_BEFORE
  field :notify_at, type: Integer, default: 8
  field :locale, type: Symbol, default: :en
  field :reset_password_token, type: String
  field :reset_password_at, type: Time

  has_many :user_tokens, dependent: :delete
  has_many :critical_periods, dependent: :delete
  has_many :future_critical_periods, dependent: :delete
  has_many :regular_days, dependent: :delete
  has_many :user_web_subscriptions, dependent: :delete

  index({ email: 1 }, { unique: true })
  index({ reset_password_token: 1 }, { unique: true, sparse: true })


  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, confirmation: true
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.zones_map.keys }
  validate :validate_notify_before
  validates :notify_at, presence: true, hour: true
  validates :locale, inclusion: { in: ALLOWED_LOCALES.keys }
  validates :reset_password_token, uniqueness: true, allow_nil: true


  # Get first upcoming future critical period.
  #
  # @param date [Date]
  #
  # @return [FutureCriticalPeriod]
  def upcoming_critical_period(date)
    future_critical_periods.upcoming(date).first
  end


  # Return time object in user's timezone.
  #
  # @param time [Time]
  #
  # @return [ActiveSupport::TimeWithZone]
  def in_time_zone(time)
    time.in_time_zone(time_zone)
  end


  # Get today date for user.
  #
  # @return [Date]
  def today_date
    in_time_zone(Time.now).to_date
  end


  # Create token for user and return raw string for it.
  #
  # @return [String]
  def create_token
    loop do
      token = SecureRandom.hex
      user_token = user_tokens.build(token: token)
      if user_token.valid?
        user_token.save
        break token
      end
    end
  end


  # Generate reset password data for user
  #
  # @return [String]
  def generate_reset_password
    loop do
      token = SecureRandom.hex
      self.reset_password_token = SecureRandom.hex
      self.reset_password_at = Time.now
      if valid?
        save
        break token
      end
    end
  end


  # Find user by token if it's not expired
  #
  # @return [self]
  def self.find_by_reset_token(token)
    where(reset_password_token: token).where(:reset_password_at.gt => Time.now - 1.hour).first
  end


  private

  # Validate #notify_before to have correct values.
  def validate_notify_before
    errors.add(:notify_before, :not_unique_values) if notify_before != notify_before.uniq

    notify_before.each do |val|
      unless ALLOWED_NOTIFY_BEFORE.include?(val)
        errors.add(:notify_before, :not_allowed_values)
        break
      end
    end
  end
end
