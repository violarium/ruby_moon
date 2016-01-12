require 'rails_helper'

describe NotificationSender do
  let(:sender) { NotificationSender.new }

  describe '#notify_upcoming' do
    let(:user) { FactoryGirl.create(:user) }

    it 'sends notification for critical period by mail' do
      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))

      mail = double('notify_mail_period')
      expect(PeriodsMailer).to receive(:critical_period).with(p).and_return(mail)
      expect(mail).to receive(:deliver_now)

      Timecop.freeze(Time.new(2015, 1, 27, 10, 0, 0)) do
        sender.notify_upcoming
      end
    end

    it 'deletes notification notes' do
      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 9, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 8, 0, 0))

      Timecop.freeze(Time.new(2015, 1, 27, 10, 0, 0)) do
        sender.notify_upcoming
        expect(p.reload.notifications.count).to eq 0
      end
    end

    it 'does not send notifications which have not came' do
      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))

      expect(PeriodsMailer).not_to receive(:critical_period)

      Timecop.freeze(Time.new(2015, 1, 26, 10, 0, 0)) do
        sender.notify_upcoming
      end
    end

    it 'does not delete notification notes which are not sent' do
      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 26, 10, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 11, 0, 0))

      Timecop.freeze(Time.new(2015, 1, 26, 10, 0, 0)) do
        sender.notify_upcoming
        expect(p.reload.notifications.count).to eq 2
      end
    end
  end
end