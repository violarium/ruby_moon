# Preview all emails at http://localhost:3000/rails/mailers/periods_mailer
class PeriodsMailerPreview < ActionMailer::Preview
  User::ALLOWED_LOCALES.keys.each do |locale|
    define_method "critical_period_#{locale}" do
      user = User.where(email: 'example@email.net').first
      user.delete unless user.nil?

      user = User.create!(email: 'example@email.net', password: '123456', locale: locale)
      period = user.future_critical_periods.create!(from: Date.today + 2.days, to: Date.today + 4.days)

      PeriodsMailer.critical_period(period)
    end
  end
end
