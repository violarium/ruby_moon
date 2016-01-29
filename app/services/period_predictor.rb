# Predictor for critical days.
class PeriodPredictor
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
    future_intervals = future_intervals_for_user(user)

    if future_intervals.length > 0
      intervals_to_keep = []
      period_to_remove = []
      existing_periods = user.future_critical_periods.all.to_a
      existing_periods.each do |existing|
        existing_interval = { from: existing.from, to: existing.to }
        if future_intervals.include?(existing_interval)
          intervals_to_keep.push(existing_interval)
        else
          period_to_remove.push(existing)
        end
      end
      intervals_to_create = future_intervals - intervals_to_keep

      period_to_remove.each { |existing_period| existing_period.delete }
      intervals_to_create.each { |data| user.future_critical_periods.create!(data) }

      @notification_builder.rebuild_for(user)
      true
    else
      user.future_critical_periods.delete_all
      false
    end
  end


  private


  # Get future intervals for user.
  #
  # @param user [User]
  #
  # @return [Array]
  def future_intervals_for_user(user)
    future_intervals = []
    periods = user.critical_periods.order_by(:from => 'desc').limit(@to_consider).all.to_a
    if periods.length > 0
      average_period_values = average_period_values(periods)
      average_cycle = average_period_values[:average_cycle]
      average_length = average_period_values[:average_length]

      future_period_from = periods[0].from
      @to_predict.times do ||
        future_period_from = future_period_from + average_cycle.days
        future_period_to = future_period_from + average_length.days
        future_intervals.push(from: future_period_from, to: future_period_to)
      end
    end
    future_intervals
  end


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