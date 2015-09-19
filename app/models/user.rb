class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include PasswordsConcern

  field :email, type: String
  field :encrypted_password, type: String
  field :time_zone, type: String

  has_many :critical_periods
  has_many :future_critical_periods

  index({ email: 1 }, { unique: true })


  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i }
  validates :password, presence: true, confirmation: true
  validates :time_zone, inclusion: { in: ActiveSupport::TimeZone.zones_map.keys }


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
end
