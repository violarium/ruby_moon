# Form to work with calendar day.
#
# It encapsulates logic to validate and handle all the data for received calendar day.
# This form object creates, changes or deletes critical periods and related data.
# This is, actually, facade.
class CalendarDayForm
  include FormObject

  DELETE_WAY_HEAD = 'head'
  DELETE_WAY_TAIL = 'tail'
  DELETE_WAY_ENTIRELY = 'entirely'

  IS_CRITICAL_ON = 'on'
  IS_CRITICAL_OFF = 'off'

  attr_accessor :is_critical, :delete_way, :critical_day_value

  validates :is_critical, inclusion: { in: [true, false] }
  validates :delete_way, inclusion: { in: [DELETE_WAY_HEAD, DELETE_WAY_TAIL, DELETE_WAY_ENTIRELY] }
  validates :critical_day_value, inclusion: { in: [CriticalDay::VALUE_UNKNOWN, CriticalDay::VALUE_SMALL,
                                                   CriticalDay::VALUE_MEDIUM, CriticalDay::VALUE_LARGE] }
  validate :validate_critical_period


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

    super(params.slice(:is_critical, :delete_way, :critical_day_value))

    if @is_critical.nil?
      @is_critical = !current_critical_period.nil?
      rebuild_critical_period
    end

    if @delete_way.nil?
      @delete_way = DELETE_WAY_ENTIRELY
      rebuild_critical_period
    end

    if @critical_day_value.nil?
      critical_day = current_critical_day
      @critical_day_value = critical_day.nil? ? CriticalDay::VALUE_UNKNOWN : critical_day.value
    end
  end


  def is_critical=(is_critical)
    if is_critical == IS_CRITICAL_OFF
      is_critical = false
    elsif is_critical == IS_CRITICAL_ON
      is_critical = true
    end
    @is_critical = is_critical
    rebuild_critical_period
  end


  def delete_way=(delete_way)
    @delete_way = delete_way
    rebuild_critical_period
  end


  # Submit the form.
  #
  # @return [Boolean]
  def submit
    if valid?
      unless @critical_period.nil?
        if @delete_critical_period
          @critical_period.delete
        else
          critical_day = @critical_period.critical_day_by_date(@date)
          critical_day = @critical_period.critical_days.build(date: @date) if critical_day.nil?
          critical_day.value = @critical_day_value
          @critical_period.cleanup_critical_days
          @critical_period.save!
        end
      end
      true
    else
      false
    end
  end


  private


  # Rebuild critical period to validate, save or delete later.
  def rebuild_critical_period
    period = current_critical_period
    delete = false

    period_helper = CriticalPeriodHelper.new
    if @is_critical
      period = period_helper.extend_or_new(period, @user, @date)
    elsif !period.nil?
      period, delete = period_helper.cut_or_mark_to_delete(period, @date, @delete_way)
    end

    @critical_period = period
    @delete_critical_period = delete
  end


  # Validate critical period according to current form data.
  # If there are no critical period to validate, it's normal behaviour.
  def validate_critical_period
    if !@delete_critical_period && !@critical_period.nil? && @critical_period.invalid?
      @critical_period.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end


  # Get current critical period.
  #
  # @return [CriticalPeriod]
  def current_critical_period
    @user.critical_periods.has_date(@date).first
  end


  # Get current critical day.
  #
  # @return [CriticalDay]
  def current_critical_day
    period = current_critical_period
    critical_day = nil
    unless period.nil?
      critical_day = period.critical_day_by_date(@date)
    end
    critical_day
  end


  class CriticalPeriodHelper
    # Extend existing or near period or get new.
    def extend_or_new(period, user, date)
      if period.nil?
        period = user.critical_periods.near_by_date(date).first
        if period.nil?
          period = user.critical_periods.build(from: date, to: date)
        else
          period.append_date(date)
        end
      end
      period
    end

    # Cut period or mark it to delete.
    def cut_or_mark_to_delete(period, date, delete_way)
      delete = false
      new_period_from = period.from
      new_period_to = period.to

      if delete_way == CalendarDayForm::DELETE_WAY_TAIL
        new_period_to = date - 1.day
      elsif delete_way == CalendarDayForm::DELETE_WAY_HEAD
        new_period_from = date + 1.day
      end

      if new_period_from > new_period_to || delete_way == CalendarDayForm::DELETE_WAY_ENTIRELY
        delete = true
      else
        period.from = new_period_from
        period.to = new_period_to
        period.cleanup_critical_days
      end

      [period, delete]
    end
  end
end