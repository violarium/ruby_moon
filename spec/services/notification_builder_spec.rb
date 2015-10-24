require 'rails_helper'

describe NotificationBuilder do
  let(:builder) { NotificationBuilder.new }

  describe '#rebuild_for' do
    let(:user) { FactoryGirl.create(:user) }

    describe 'according to user settings' do
      before do
        user.time_zone = 'Moscow'
        user.notify_before = [0, 2]
        user.notify_at = 10
        user.save!
      end

      it 'rebuilds notifications for all the future critical periods' do
        user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        user.future_critical_periods.create!(from: Date.new(2015, 2, 20), to: Date.new(2015, 2, 25))

        builder.rebuild_for(user)

        p1 = user.future_critical_periods.all[0]
        p2 = user.future_critical_periods.all[1]

        expect(p1.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 1, 29, 10))
        expect(p1.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 1, 31, 10))

        expect(p2.notifications[0].time).to eq(Time.find_zone('Moscow').local(2015, 2, 20, 10))
        expect(p2.notifications[1].time).to eq(Time.find_zone('Moscow').local(2015, 2, 22, 10))
      end


      describe 'when for some periods there are already notifications' do
        before do
          f = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
          f.notifications.create!(time: Time.new(2015, 1, 29))
        end

        it 'deletes them before creating new' do
          builder.rebuild_for(user)

          f = user.future_critical_periods.all[0]
          expect(f.notifications.count).to eq 2
        end
      end
    end

    describe 'when user do not want to have notifications' do
      before do
        user.notify_before = []
        user.save!
      end

      it 'should not build them and delete existing ones' do
        f = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 1, 30))
        f.notifications.create!(time: Time.new(2015, 1, 29))
        builder.rebuild_for(user)

        expect(user.future_critical_periods.all[0].notifications.count).to eq 0
      end
    end
  end
end
