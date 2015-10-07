# Class for user model.
#
# Fields:
#   email - user email.
#   password and password_confirmation - fields for password, encrypted_password - encrypted value.
#   time_zone - current user timezone from ActiveSupport::TimeZone.
#   notification_days - days in which notifications should be sent, 0 means in day of event, 1 - in day before event.
#   notification_time - time to send notification about event (see notification_days).
#
# Associations:
#   critical_periods
#   future_critical_periods
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include PasswordsConcern

  # Allowed values for notification days.
  ALLOWED_NOTIFICATION_DAYS = [0, 1, 2]

  field :email, type: String
  field :encrypted_password, type: String
  field :time_zone, type: String, default: 'UTC'
  field :notification_days, type: Array, default: ALLOWED_NOTIFICATION_DAYS
  field :notification_time, type: Integer, default: 8

  has_many :critical_periods
  has_many :future_critical_periods

  index({ email: 1 }, { unique: true })


  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, presence: true, confirmation: true
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.zones_map.keys }
  validate :validate_notification_days
  validates :notification_time, presence: true, numericality: { only_integer: true,
                                                greater_than_or_equal_to: 0, less_than_or_equal_to: 23 }


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
  # @param [ActiveSupport::TimeWithZone]
  def in_time_zone(time)
    time.in_time_zone(time_zone)
  end


  private

  # Validate notification days to have correct values.
  def validate_notification_days
    notification_days.each do |val|
      unless ALLOWED_NOTIFICATION_DAYS.include?(val)
        errors.add(:notification_days, :not_allowed_values)
        break
      end
    end
  end
end
