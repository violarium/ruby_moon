require 'rails_helper'

describe PeriodsMailer, type: :mailer do
  it 'sends mail' do
    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.today, to: Date.today + 3.days)
    expect { PeriodsMailer.critical_period(period).deliver_now }.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  it 'raises exception when future critical period has no user' do
    FutureCriticalPeriod.collection.insert_one({from: Time.new(2015, 1, 1), to: Time.new(2015, 1, 2)})
    period = FutureCriticalPeriod.first
    expect { PeriodsMailer.critical_period(period).deliver_now }.to raise_error(ArgumentError)
  end
end
