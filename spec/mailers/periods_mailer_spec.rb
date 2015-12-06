require 'rails_helper'

describe PeriodsMailer, type: :mailer do
  it 'sends mail' do
    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.today, to: Date.today + 3.days)
    expect { PeriodsMailer.critical_period(period).deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end
end
