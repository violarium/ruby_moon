class CriticalPeriod
  PERIOD_MARGIN = 7

  include Mongoid::Document
  include Mongoid::Timestamps

  field :from, type: Date
  field :to, type: Date

  belongs_to :user

  validates :from, presence: true
  validates :to, presence: true
  validates :user, presence: true
  validate :validate_to_gte_from, if: :dates_not_nil?
  validate :validate_period_intersection, if: :user_not_nil?
  validate :validate_period_margin, if: [:user_not_nil?, :dates_not_nil?]


  scope :has_date, -> (date) do
    where(:from.lte => date, :to.gte => date)
  end


  # User is not nil.
  #
  # @return [Boolean]
  def user_not_nil?
    !user.nil?
  end


  # Both dates from and to are not nil.
  #
  # @return [Boolean]
  def dates_not_nil?
    !from.nil? && !to.nil?
  end


  private


  # Validation method to check if "to" greater of equal to "from".
  def validate_to_gte_from
    if from > to
      errors[:base] << 'Date from should be less or equal to date to'
    end
  end


  # Validation method to check if current period intersects with another one.
  def validate_period_intersection
    period_count = user.critical_periods.or({:from.gte => from, :to.lte => to},
                                            {:from.lte => from, :to.gte => to},
                                            {:from.lte => from, :to.gte => from},
                                            {:from.lte => to,   :to.gte => to})
                                         .where(:id.ne => id).count
    if period_count > 0
      errors[:base] << 'Period intersects with other one'
    end
  end


  # Validation method to check if current period has enough margin with others.
  def validate_period_margin
    before_range = (from - PERIOD_MARGIN.days) .. from
    before_count = user.critical_periods.or({:to => before_range}, {:from => before_range}).where(:id.ne => id).count
    if before_count > 0
      errors[:base] << 'There are period before too close'
    end

    after_range = to .. (to + PERIOD_MARGIN.days)
    after_count = user.critical_periods.or({:from => after_range}, {:to => after_range}).where(:id.ne => id).count
    if after_count > 0
      errors[:base] << 'There are period after too close'
    end
  end
end
