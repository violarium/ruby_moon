# Predictor for critical days.
class PeriodPredictor
  # Default period cycle.
  DEFAULT_CYCLE = 28

  def initialize(notification_builder, default_cycle, to_consider, to_predict)
    @notification_builder = notification_builder
    @default_cycle = default_cycle
    @to_consider = to_consider
    @to_predict = to_predict
  end


  # Refresh predicted periods for user. Remove old, create new.
  #
  # @param user [User]
  #
  # @return [Boolean] - was predicted anything or not.
  def refresh_for(user)
    user.future_critical_periods.delete_all

    periods = user.critical_periods.order_by(:from => 'desc').limit(@to_consider).all.to_a
    if periods.length > 0
      average_period_values = average_period_values(periods)
      average_cycle = average_period_values[:average_cycle]
      average_length = average_period_values[:average_length]

      future_period_from = periods[0].from
      @to_predict.times do ||
        future_period_from = future_period_from + average_cycle.days
        future_period_to = future_period_from + average_length.days
        user.future_critical_periods.create!(from: future_period_from, to: future_period_to)
      end
      @notification_builder.rebuild_for(user)
      true
    else
      false
    end
  end


  # Get default predictor.
  def self.default_predictor
    self.new(NotificationBuilder.new, DEFAULT_CYCLE, 4, 3)
  end


  private

  # Get average values for list of periods.
  #
  # @param periods [Array<CriticalPeriod>]
  #
  # @return [Hash]
  def average_period_values(periods)
    period_cycles = []
    period_lengths = []

    last_period = nil
    periods.each do |period|
      unless last_period.nil?
        period_cycles.push (last_period.from - period.from).to_i
      end
      period_lengths.push (period.to - period.from).to_i
      last_period = period
    end

    if period_cycles.length > 0
      average_cycle = (period_cycles.sum / period_cycles.length.to_f).round
    else
      average_cycle = @default_cycle
    end
    average_length = (period_lengths.sum / period_lengths.length.to_f).round

    { average_cycle: average_cycle, average_length: average_length }
  end
end