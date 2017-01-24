require 'rails_helper'

describe NotificationSender do
  describe '#notify_upcoming' do
    let(:user) { FactoryGirl.create(:user) }

    it 'sends notification for critical period with all available senders' do
      sender_1 = double('sender_1')
      sender_2 = double('sender_1')
      sender = NotificationSender.new([sender_1, sender_2])

      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))

      expect(sender_1).to receive(:send_notification).with(p)
      expect(sender_2).to receive(:send_notification).with(p)

      Timecop.freeze(Time.new(2015, 1, 27, 10, 0, 0)) do
        sender.notify_upcoming
      end
    end

    it 'deletes notification notes' do
      sender = NotificationSender.new([])

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
      sender_1 = double('sender_1')
      sender_2 = double('sender_1')
      sender = NotificationSender.new([sender_1, sender_2])

      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))

      expect(sender_1).not_to receive(:send_notification)
      expect(sender_2).not_to receive(:send_notification)

      Timecop.freeze(Time.new(2015, 1, 26, 10, 0, 0)) do
        sender.notify_upcoming
      end
    end

    it 'does not delete notification notes which are not sent' do
      sender = NotificationSender.new([])

      p = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
      p.notifications.create!(time: Time.new(2015, 1, 26, 10, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))
      p.notifications.create!(time: Time.new(2015, 1, 27, 11, 0, 0))

      Timecop.freeze(Time.new(2015, 1, 26, 10, 0, 0)) do
        sender.notify_upcoming
        expect(p.reload.notifications.count).to eq 2
      end
    end

    describe 'for future critical period without user' do
      before do
        FutureCriticalPeriod.collection.insert_one({from: Time.new(2015, 1, 29), to: Time.new(2015, 1, 30)})
        @period = FutureCriticalPeriod.first
        @period.notifications.create!(time: Time.new(2015, 1, 27, 10, 0, 0))
      end

      it 'does not send notifications to periods without users' do
        sender_1 = double('sender_1')
        sender_2 = double('sender_1')
        sender = NotificationSender.new([sender_1, sender_2])

        expect(sender_1).not_to receive(:send_notification)
        expect(sender_2).not_to receive(:send_notification)

        Timecop.freeze(Time.new(2015, 1, 27, 10, 0, 0)) do
          sender.notify_upcoming
        end
      end

      it 'deletes it period notifications which were to send' do
        sender = NotificationSender.new([])
        Timecop.freeze(Time.new(2015, 1, 27, 10, 0, 0)) do
          sender.notify_upcoming
        end

        @period.reload
        expect(@period.notifications.count).to eq 0
      end
    end
  end
end