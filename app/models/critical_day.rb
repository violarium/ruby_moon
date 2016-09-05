class CriticalDay
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :critical_period

  field :date, type: Date
  field :value, type: String, default: 'unknown'

  validates :date, presence: true
  validates :value, inclusion: { in: %w(unknown small medium large) }
  validates :critical_period, presence: true
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