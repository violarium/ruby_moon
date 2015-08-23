# Concern, with describes classic period, which belongs to user.
module UserPeriodConcern
  extend ActiveSupport::Concern

  # Period margin defines how close periods could be to each other.
  PERIOD_MARGIN = 7

  included do
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


    # Scope to select periods, which have date
    scope :has_date, -> (date) do
      where(:from.lte => date, :to.gte => date)
    end

    # Scope to select periods near by date - within PERIOD_MARGIN
    scope :near_by_date, -> (date) do
      self.or({:from => date .. date + PERIOD_MARGIN.days},
              {:to => date - PERIOD_MARGIN.days .. date},
              {:from.lte => date, :to.gte => date})
    end

    # Scope to select periods between 2 dates - periods should intersect within this 2 dates:
    # it could be inside of them, or overlap and etc.
    scope :between_dates, -> (date_from, date_to) do
      self.or({:from.gte => date_from, :to.lte => date_to},
              {:from.lte => date_from, :to.gte => date_to},
              {:from.lte => date_from, :to.gte => date_from},
              {:from.lte => date_to, :to.gte => date_to})
    end
  end


  protected

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


  # Validation method to check if "to" greater of equal to "from".
  def validate_to_gte_from
    if from > to
      errors[:base] << 'Date from should be less or equal to date to'
    end
  end


  # Validation method to check if current period intersects with another one.
  def validate_period_intersection
    period_count = self.class
                       .where(:user_id => user.id, :id.ne => id)
                       .or({:from.gte => from, :to.lte => to},
                           {:from.lte => from, :to.gte => to},
                           {:from.lte => from, :to.gte => from},
                           {:from.lte => to,   :to.gte => to})
                       .count
    if period_count > 0
      errors[:base] << 'Period intersects with other one'
    end
  end


  # Validation method to check if current period has enough margin with others.
  def validate_period_margin
    periods_query = self.class.where(:user_id => user.id, :id.ne => id)

    before_count = periods_query.near_by_date(from).count
    if before_count > 0
      errors[:base] << 'There are period before too close'
    end

    after_count = periods_query.near_by_date(to).count
    if after_count > 0
      errors[:base] << 'There are period after too close'
    end
  end
end