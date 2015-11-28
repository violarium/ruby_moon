require 'rails_helper'

describe NotificationBuilder do
  let(:builder) { NotificationBuilder.new }

  describe '#rebuild_for' do
    let(:user) { FactoryGirl.create(:user, time_zone: 'Moscow', notify_before: [0, 2], notify_at: 10) }

    describe 'according to user settings' do
      it 'creates future notifications for all the future critical periods' do
        p1 = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        p2 = user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))
        expect(Time).to receive(:current).and_return(Time.new(2015, 1, 1))

        builder.rebuild_for(user)
        p1.reload
        p2.reload

        expect(p1.notifications.count).to eq 2
        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 29, 10))
        expect(p1.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications.count).to eq 2
        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end

      it 'does not create notification which are in the past' do
        p1 = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        p2 = user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))
        expect(Time).to receive(:current).and_return(Time.find_zone('Moscow').local(2015, 1, 30))

        builder.rebuild_for(user)
        p1.reload
        p2.reload

        expect(p1.notifications.count).to eq 1
        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications.count).to eq 2
        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end

      it 'does not delete past notification which we could recreate' do
        # if user has not changed his notification settings but notification has not been sent somehow

        p1 = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        p2 = user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))
        p1.notifications.create!(time: Time.find_zone('Moscow').local(2015, 1, 29, 10))
        expect(Time).to receive(:current).and_return(Time.find_zone('Moscow').local(2015, 1, 30))

        builder.rebuild_for(user)
        p1.reload
        p2.reload

        expect(p1.notifications.count).to eq 2
        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 29, 10))
        expect(p1.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications.count).to eq 2
        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end

      it 'deletes past notification which we could not recreate' do
        # if user has changed his notification settings but notification has not been sent somehow

        p1 = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        p2 = user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))
        p1.notifications.create!(time: Time.find_zone('Moscow').local(2015, 1, 29, 11))
        expect(Time).to receive(:current).and_return(Time.find_zone('Moscow').local(2015, 1, 30))

        builder.rebuild_for(user)
        p1.reload
        p2.reload

        expect(p1.notifications.count).to eq 1
        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications.count).to eq 2
        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end

      it 'deletes future notification which we could not recreate' do
        # if user has changed his notification settings

        p1 = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        p2 = user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))
        p1.notifications.create!(time: Time.find_zone('Moscow').local(2015, 1, 30, 10))
        expect(Time).to receive(:current).and_return(Time.new(2015, 1, 1))

        builder.rebuild_for(user)
        p1.reload
        p2.reload

        expect(p1.notifications.count).to eq 2
        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 29, 10))
        expect(p1.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications.count).to eq 2
        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end


      describe 'when user do not want to have notifications' do
        before do
          user.notify_before = []
          user.save!
        end

        it 'does not build them and delete existing ones' do
          f = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
          f.notifications.create!(time: Time.new(2015, 1, 29))
          builder.rebuild_for(user)
          f.reload

          expect(f.notifications.count).to eq 0
        end
      end
    end
  end
end
