class PeriodsMailer < ApplicationMailer
  def critical_period(future_period)
    user = future_period.user
    raise ArgumentError, 'User of period is nil' if user.nil?

    days_left = (future_period.from - user.today_date).to_i
    @future_period = future_period
    @duration = (future_period.to - future_period.from).to_i

    I18n.with_locale(user.locale) do
      @subject = t('mailers.periods.critical_period.subject', days_left: days_left, count: days_left)
      mail(to: user.email, subject: @subject)
    end
  end
end
