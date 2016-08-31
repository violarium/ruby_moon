class CriticalDay
  include Mongoid::Document
  include Mongoid::Timestamps

  embedded_in :critical_period

  field :date, type: Date
  field :value, type: Symbol, default: :unknown

  validates :date, presence: true
  validates :value, inclusion: { in: [:unknown, :small, :medium, :large] }
  validates :critical_period, presence: true
end