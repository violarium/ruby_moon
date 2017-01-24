require 'rails_helper'

describe NotificationSender::MailSender do
  it 'should call mailer' do
    period = double('period')
    mailer = double('mailer')
    expect(PeriodsMailer).to receive(:critical_period).with(period).and_return(mailer)
    expect(mailer).to receive(:deliver_now)

    NotificationSender::MailSender.new.send_notification(period)
  end
end