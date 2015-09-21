# Form to work with calendar day.
#
# It encapsulates logic to validate and handle all the data for received calendar day.
# This form object creates, changes or deletes critical periods and related data.
# This is, actually, facade.
class CalendarDayForm
  include FormObject
  include ActiveModel::Validations::Callbacks

  attr_accessor :critical_day, :period_length, :delete_period

  before_validation :build_period
  validate :validate_period, if: :save_period?

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

    super(params.slice(:critical_day, :period_length, :delete_period))

    @critical_day = @user.critical_periods.has_date(@date).count > 0 if @critical_day.nil?
    @period_length ||= 1
    @delete_period ||= 'all'
  end


  def critical_day=(critical_day)
    critical_day = false if critical_day == '0'
    @critical_day = critical_day
  end


  def period_length=(period_length)
    period_length = period_length.to_i if period_length.is_a? String
    @period_length = period_length
  end


  # Submit the form.
  #
  # @return [Boolean]
  def submit
    if valid?
      @period.save! if save_period?
      @period.delete if delete_period?
      true
    else
      false
    end
  end


  private

  # Build period according to input data.
  def build_period
    @period = @user.critical_periods.has_date(@date).first
    if @period.nil?
      if critical_day
        @period = @user.critical_periods.near_by_date(@date).first
        if @period.nil?
          @period = @user.critical_periods.new(from: @date, to: period_end_date)
        else
          @period.append_date(@date)
        end
      end
    elsif !critical_day
      if delete_period == 'tail'
        @period.to = @date - 1.day
      elsif delete_period == 'head'
        @period.from = @date + 1.day
      end
    end
  end

  # Should we save period?
  #
  # @return [Boolean]
  def save_period?
    !@period.nil? && @period.changed? && !delete_period?
  end


  # Should we delete period?
  #
  # @return [Boolean]
  def delete_period?
    !@period.nil? && !critical_day && (@period.from > @period.to && %w(tail head).include?(delete_period) || delete_period == 'all')
  end


  # Validation period method.
  def validate_period
    unless @period.valid?
      @period.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end


  # End date for new period.
  #
  # @return [Date]
  def period_end_date
    day_offset = period_length - 1
    @date + day_offset.days
  end
end