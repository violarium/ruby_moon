class CriticalPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: Date
  field :to, type: Date

  belongs_to :user
end
