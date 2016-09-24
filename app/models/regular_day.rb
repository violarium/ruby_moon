class RegularDay
  include Mongoid::Document
  include Mongoid::Timestamps

  LOVE_UNKNOWN = 'unknown'
  LOVE_UNPROTECTED = 'unprotected'
  LOVE_PROTECTED = 'protected'

  belongs_to :user

  field :date, type: Date
  field :love, type: String, default: LOVE_UNKNOWN
  field :notes, type: String, default: ''

  index({ user_id: 1, date: 1 }, { unique: true })

  validates :user, presence: true
  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :love, inclusion: { in: [LOVE_UNKNOWN, LOVE_UNPROTECTED, LOVE_PROTECTED] }
end