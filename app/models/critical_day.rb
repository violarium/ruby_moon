class CriticalDay
  include Mongoid::Document
  include Mongoid::Timestamps

  VALUE_UNKNOWN = 'unknown'
  VALUE_SMALL = 'small'
  VALUE_MEDIUM = 'medium'
  VALUE_LARGE = 'large'

  embedded_in :critical_period

  field :date, type: Date
  field :value, type: String, default: VALUE_UNKNOWN

  validates :date, presence: true
  validates :value, inclusion: { in: [VALUE_UNKNOWN, VALUE_SMALL, VALUE_MEDIUM, VALUE_LARGE] }
  validate :validate_period_range


  private

  # Validate if critical day within critical period range.
  def validate_period_range
    if !critical_period.nil? && !date.nil?
      if date < critical_period.from || date > critical_period.to
        errors.add(:date, :out_of_range)
      end
    end
  end
end