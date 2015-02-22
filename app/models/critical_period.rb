class CriticalPeriod
  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: Date
  field :to, type: Date

  belongs_to :user

  validates :from, presence: true
  validates :to, presence: true
  validates :user, presence: true
  validate :to_gte_from
  validate :period_intersection


  scope :has_date, -> (date) do
    where(:from.lte => date, :to.gte => date)
  end


  private


  # Validation method to check if "to" greater of equal to "from".
  def to_gte_from
    if (!from.nil?) && (!to.nil?) && (from > to)
      errors[:base] << 'Date from should be less or equal to date to'
    end
  end


  # Validation method to check if current period intersects with another one.
  def period_intersection
    unless user.nil?
      period_count = user.critical_periods.or({:from.gte => from, :to.lte => to},
                                              {:from.lte => from, :to.gte => to},
                                              {:from.lte => from, :to.gte => from},
                                              {:from.lte => to,   :to.gte => to})
                                           .where(:id.ne => id).count
      if period_count > 0
        errors[:base] << 'Period intersects with other one'
      end
    end
  end
end
