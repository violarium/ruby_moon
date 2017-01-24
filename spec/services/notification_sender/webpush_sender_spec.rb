require 'rails_helper'

describe NotificationSender::WebpushSender do
  it 'should call webpush' do
    vapid = {private_key: 'private_key', public_key: 'public_key', subject: 'subject'}
    sender = NotificationSender::WebpushSender.new(vapid)

    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
    user.user_web_subscriptions.create!({endpoint: 'e1', p256dh: 'p1', auth: 'a1'})
    user.user_web_subscriptions.create!({endpoint: 'e2', p256dh: 'p2', auth: 'a2'})

    expect(::Webpush).to receive(:payload_send).with({message: anything,
                                                      endpoint: 'e1',
                                                      p256dh: 'p1',
                                                      auth: 'a1',
                                                      vapid: vapid})

    expect(::Webpush).to receive(:payload_send).with({message: anything,
                                                      endpoint: 'e2',
                                                      p256dh: 'p2',
                                                      auth: 'a2',
                                                      vapid: vapid})

    sender.send_notification(period)
  end
end