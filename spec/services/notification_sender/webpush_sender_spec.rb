require 'rails_helper'

describe NotificationSender::WebpushSender do
  let(:ttl) { NotificationSender::WebpushSender::TTL }

  it 'should call webpush' do
    vapid = {private_key: 'private_key', public_key: 'public_key', subject: 'subject'}
    sender = NotificationSender::WebpushSender.new(vapid)

    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
    user.user_web_subscriptions.create!(endpoint: 'e1', p256dh: 'p1', auth: 'a1')
    user.user_web_subscriptions.create!(endpoint: 'e2', p256dh: 'p2', auth: 'a2')

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e1',
                                                     p256dh: 'p1',
                                                     auth: 'a1',
                                                     vapid: vapid,
                                                     ttl: ttl)

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e2',
                                                     p256dh: 'p2',
                                                     auth: 'a2',
                                                     vapid: vapid,
                                                     ttl: ttl)

    sender.send_notification(period)
  end


  it 'should automatically delete invalid subscriptions' do
    vapid = {private_key: 'private_key', public_key: 'public_key', subject: 'subject'}
    sender = NotificationSender::WebpushSender.new(vapid)

    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
    user.user_web_subscriptions.create!(endpoint: 'e1', p256dh: 'p1', auth: 'a1')
    user.user_web_subscriptions.create!(endpoint: 'e2', p256dh: 'p2', auth: 'a2')

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e1',
                                                     p256dh: 'p1',
                                                     auth: 'a1',
                                                     vapid: vapid,
                                                     ttl: ttl)

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e2',
                                                     p256dh: 'p2',
                                                     auth: 'a2',
                                                     vapid: vapid,
                                                     ttl: ttl).and_raise(Webpush::InvalidSubscription, 'Invalid')

    expect { sender.send_notification(period) }.to change { user.user_web_subscriptions.count }.by(-1)
    expect(user.reload.user_web_subscriptions.first.endpoint).to eq 'e1'
  end


  it 'should not stop on different webpush response error' do
    vapid = {private_key: 'private_key', public_key: 'public_key', subject: 'subject'}
    sender = NotificationSender::WebpushSender.new(vapid)

    user = FactoryGirl.create(:user)
    period = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
    user.user_web_subscriptions.create!(endpoint: 'e1', p256dh: 'p1', auth: 'a1')
    user.user_web_subscriptions.create!(endpoint: 'e2', p256dh: 'p2', auth: 'a2')

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e1',
                                                     p256dh: 'p1',
                                                     auth: 'a1',
                                                     vapid: vapid,
                                                     ttl: ttl)

    expect(::Webpush).to receive(:payload_send).with(message: anything,
                                                     endpoint: 'e2',
                                                     p256dh: 'p2',
                                                     auth: 'a2',
                                                     vapid: vapid,
                                                     ttl: ttl).and_raise(Webpush::ResponseError, 'Error')

    expect { sender.send_notification(period) }.not_to(change { user.user_web_subscriptions.count })
  end
end