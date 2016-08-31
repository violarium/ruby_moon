# Form to work with calendar day.
#
# It encapsulates logic to validate and handle all the data for received calendar day.
# This form object creates, changes or deletes critical periods and related data.
# This is, actually, facade.
class CalendarDayForm
  include FormObject

  attr_accessor :is_critical, :delete_way
  delegate :value, :value=, to: :critical_day, prefix: true

  validates :is_critical, inclusion: { in: [true, false] }
  validates :delete_way, inclusion: { in: %w(head tail entirely)}
  validates :critical_day_value, inclusion: { in: [:unknown, :small, :medium, :large]  }
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
    @critical_period_commander = CriticalPeriodCommander.new(@user, @date)

    super(params.slice(:is_critical, :delete_way, :critical_day_value))

    @is_critical = !current_critical_period.nil? if @is_critical.nil?
    @delete_way ||= 'entirely'
  end


  def is_critical=(is_critical)
    if is_critical == 'off'
      is_critical = false
    elsif is_critical == 'on'
      is_critical = true
    end
    @is_critical = is_critical
  end


  # Submit the form.
  #
  # @return [Boolean]
  def submit
    if valid?
      period_command = critical_period_command(current_critical_period)
      period_command.perform

      unless period_command.period.nil?
        if critical_day.critical_period.nil?
          critical_day.critical_period = period_command.period
        end
        critical_day.save!
        period_command.period.reload
      end
      true
    else
      false
    end
  end


  private


  # Validate critical period according to current form data.
  # If there are no critical period to validate, it's normal behaviour.
  def validate_critical_period
    period_command = critical_period_command(current_critical_period)
    period = period_command.period
    if period_command.require_period_validation? && !period.nil? && period.invalid?
      period.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end


  def critical_day
    if @critical_day.nil?
      period = current_critical_period
      if period.nil?
        @critical_day = nil
      else
        @critical_day = period.critical_day_by_date(@date)
      end

      @critical_day = CriticalDay.new(date: @date) if @critical_day.nil?
    end
    @critical_day
  end


  # Get current critical period.
  #
  # @return [CriticalPeriod]
  def current_critical_period
    @user.critical_periods.has_date(@date).first
  end


  # Get command to handle critical period according to current form data.
  def critical_period_command(period)
    if @is_critical
      @critical_period_commander.command_extend(period)
    else
      @critical_period_commander.command_to_cut(period, @delete_way)
    end
  end


  # Critical Period Commander
  #
  # It's a class to get command which will have period to change or delete.
  # Command could be performed to apply changes.
  class CriticalPeriodCommander
    def initialize(user, date)
      @user = user
      @date = date
    end


    # Get command to extend a period.
    def command_extend(period)
      if period.nil?
        period = @user.critical_periods.near_by_date(@date).first
        if period.nil?
          period = @user.critical_periods.build(from: @date, to: @date)
        else
          period.append_date(@date)
        end
      end

      CriticalPeriodCommand::Save.new(period)
    end


    # Get command to cut the period.
    def command_to_cut(period, delete_way)
      delete = false
      unless period.nil?
        new_period_from = period.from
        new_period_to = period.to

        if delete_way == 'tail'
          new_period_to = @date - 1.day
        elsif delete_way == 'head'
          new_period_from = @date + 1.day
        end

        if new_period_from > new_period_to || delete_way == 'entirely'
          delete = true
        else
          period.from = new_period_from
          period.to = new_period_to
        end
      end

      if delete
        CriticalPeriodCommand::Delete.new(period)
      else
        CriticalPeriodCommand::Save.new(period)
      end
    end
  end


  class CriticalPeriodCommand
    # Save command for period.
    # Performing means saving period.
    class Save
      attr_reader :period

      def initialize(period)
        @period = period
      end

      def require_period_validation?
        true
      end

      def perform
        @period.save! unless @period.nil?
      end
    end


    # Delete command for period.
    # Performing means deleting period.
    class Delete
      attr_reader :period

      def initialize(period)
        @period = period
      end

      def require_period_validation?
        false
      end

      def perform
        @period.delete unless @period.nil?
        @period = nil
      end
    end
  end
end