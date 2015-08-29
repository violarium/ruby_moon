module Calendar
  # Predictor for critical days.
  class CriticalPeriodPredictor
    # Default period cycle.
    AVERAGE_PERIOD_CYCLE = 28

    # Number of periods which will be looked for average data.
    PERIODS_TO_CONSIDER = 4

    # Refresh predicted periods for user. Remove old, create new.
    #
    # @param user [User]
    # @param to_predict [Integer] - number of periods to predict in future.
    #
    # @return [Boolean] - was predicted anything or not.
    def refresh_for(user, to_predict = 1)
      user.future_critical_periods.delete_all

      periods = user.critical_periods.order_by(:from => 'desc').limit(PERIODS_TO_CONSIDER).all.to_a
      if periods.length > 0
        average_period_values = average_period_values(periods)
        average_cycle = average_period_values[:average_cycle]
        average_length = average_period_values[:average_length]

        future_period_from = periods[0].from
        to_predict.times do ||
          future_period_from = future_period_from + average_cycle.days
          future_period_to = future_period_from + average_length.days
          user.future_critical_periods.create!(from: future_period_from, to: future_period_to)
        end
        true
      else
        false
      end
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
        average_cycle = AVERAGE_PERIOD_CYCLE
      end
      average_length = (period_lengths.sum / period_lengths.length.to_f).round

      { average_cycle: average_cycle, average_length: average_length }
    end
  end
end