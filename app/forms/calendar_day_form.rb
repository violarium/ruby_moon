class CalendarDayForm
  include ActiveModel::Model

  attr_accessor :critical_day, :period_length, :delete_period

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

    if critical_day.nil?
      self.critical_day = period.new_record? ? 0 : 1
    else
      self.critical_day = critical_day.to_i
    end
  end


  # Submit the form.
  #
  # @return [Boolean]
  def submit
    if valid?
      period.save! if save_period?
      period.delete if delete_period?
      true
    else
      false
    end
  end


  # Get period. New or existing.
  #
  # @return [CriticalPeriod]
  def period
    unless @period_initialized
      @period_initialized = true

      @period = @user.critical_periods.has_date(@date).first
      if @period.nil?
        @period = @user.critical_periods.new(from: @date, to: period_end_date)
      elsif critical_day == 0
        if delete_period == 'tail'
          @period.to = @date - 1.day
        elsif delete_period == 'head'
          @period.from = @date + 1.day
        end
      end
    end

    @period
  end

  private


  # Should we save period?
  #
  # @return [Boolean]
  def save_period?
    !delete_period? && (period.new_record? && critical_day == 1 || !period.new_record?)
  end


  # Should we delete period?
  #
  # @return [Boolean]
  def delete_period?
    !period.new_record? && critical_day == 0 && (period.from > period.to && ['tail', 'head'].include?(delete_period) || delete_period == 'all')
  end


  # Validation period method.
  def validate_period
    unless period.valid?
      period.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end


  # End date for new period.
  #
  # @return [Date]
  def period_end_date
    day_offset = period_length.to_i - 1
    day_offset = 0 if day_offset < 0
    @date + day_offset.days
  end
end