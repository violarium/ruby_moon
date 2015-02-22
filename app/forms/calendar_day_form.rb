class CalendarDayForm
  include ActiveModel::Model

  attr_accessor :has_period, :period_length, :delete_period


  # Create form object to handle calendar day.
  #
  # @param user [User]
  # @param date [Date]
  # @param params [Hash]
  #
  # @return [self]
  def initialize(user, date, params = {})
    @user = user
    @date = date
    @period = user.critical_periods.has_date(date).first
    super(params.slice(:has_period, :period_length, :delete_period))
  end


  # Submit the form
  def submit
    if @period.nil?
      @user.critical_periods.create(from: period_from_date, to: period_to_date) if has_period
    elsif !has_period
      Delete.delete(@period, delete_period, @date)
    end
  end


  private

  def period_from_date
    @date
  end

  def period_to_date
    day_offset = period_length.to_i - 1
    day_offset = 0 if day_offset < 0
    @date + day_offset.days
  end


  class Delete
    ALL = 'all'
    TAIL = 'tail'
    HEAD = 'head'

    class << self
      def delete(period, delete_way, delete_date)
        period.delete if delete_way == ALL

        if delete_way == TAIL
          period.to = delete_date - 1.day
          cut_or_delete(period)
        end

        if delete_way == HEAD
          period.from = delete_date + 1.day
          cut_or_delete(period)
        end
      end

      private

      def cut_or_delete(period)
        if period.from < period.to
          period.save!
        else
          period.delete
        end
      end
    end
  end
end