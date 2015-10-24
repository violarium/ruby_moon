require 'rails_helper'

describe PeriodPredictor do
  let(:user) { FactoryGirl.create(:user) }
  let(:notification_builder) { NotificationBuilder.new }
  let(:predictor) { PeriodPredictor.new(notification_builder, 28, 4, 1) }

  describe 'self.default_predictor' do
    it 'should create period predictor' do
      expect(PeriodPredictor.default_predictor).to be_a PeriodPredictor
    end
  end

  describe '#refresh_for' do
    before do
      allow(notification_builder).to receive(:rebuild_for)
    end


    describe 'when there are no critical periods' do
      it 'should not predict any periods' do
        expect { predictor.refresh_for(user) }.not_to change { user.future_critical_periods.count }
      end

      it 'should clear existing periods for user, if they exists' do
        user.future_critical_periods.create!(from: Date.new(2014, 1, 1), to: Date.new(2014, 1, 3))
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.to(0)
      end
    end


    describe 'when one critical period exists' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
      end

      it 'should predict one period with default interval and same length' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(1)
        predicted_period = user.future_critical_periods.first

        expect(predicted_period[:from]).to eq(Date.new(2015, 1, 29))
        expect(predicted_period[:to]).to eq(Date.new(2015, 2, 1))
      end
    end


    describe 'when 2 critical periods exist' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 8, 2), to: Date.new(2015, 8, 3))
        user.critical_periods.create!(from: Date.new(2015, 8, 16), to: Date.new(2015, 8, 19))
      end

      it 'should predict one period with average data from last 2 periods' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(1)
        predicted_period = user.future_critical_periods.first

        expect(predicted_period.from).to eq(Date.new(2015, 8, 30))
        expect(predicted_period.to).to eq(Date.new(2015, 9, 1))
      end
    end


    describe 'when 4 critical periods exist' do
      before do
        user.critical_periods.create!(from: Date.new(2014, 12, 5), to: Date.new(2014, 12, 20)) # long period
        user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
        user.critical_periods.create!(from: Date.new(2015, 1, 21), to: Date.new(2015, 1, 25))
        user.critical_periods.create!(from: Date.new(2015, 2, 12), to: Date.new(2015, 2, 14))
        user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 4))
      end

      it 'should predict one period with average data from last 4 periods' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(1)
        predicted_period = user.future_critical_periods.first

        expect(predicted_period.from).to eq(Date.new(2015, 3, 19))
        expect(predicted_period.to).to eq(Date.new(2015, 3, 22))
      end
    end


    describe 'when predicted critical period already exists' do
      let!(:old_predicted) { user.future_critical_periods.create!(from: Date.new(2014, 1, 1),
                                                                  to: Date.new(2014, 1, 3)) }
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
      end

      it 'should remove old predicted period' do
        expect { predictor.refresh_for(user) }.not_to change { user.future_critical_periods.count }
        predicted_period = user.future_critical_periods.first

        expect(predicted_period.from).not_to eq(old_predicted.from)
        expect(predicted_period.to).not_to eq(old_predicted.to)
      end

      it 'should not remove predicted periods from different user' do
        another_user = FactoryGirl.create(:user, email: 'another@email.org')
        another_user.future_critical_periods.create!(from: Date.new(2014, 1, 1), to: Date.new(2014, 1, 3))

        expect { predictor.refresh_for(another_user) }.not_to change { user.future_critical_periods.count }
      end
    end


    describe 'when we want to predict 3 periods' do
      let(:predictor) { PeriodPredictor.new(notification_builder, 28, 4, 3) }

      before do
        user.critical_periods.create!(from: Date.new(2015, 8, 2), to: Date.new(2015, 8, 3))
        user.critical_periods.create!(from: Date.new(2015, 8, 16), to: Date.new(2015, 8, 19))
      end

      it 'should predict one period with average data from last 3 periods' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(3)
        predicted_periods = user.future_critical_periods.all.to_a

        expect(predicted_periods[0].from).to eq(Date.new(2015, 8, 30))
        expect(predicted_periods[0].to).to eq(Date.new(2015, 9, 1))

        expect(predicted_periods[1].from).to eq(Date.new(2015, 9, 13))
        expect(predicted_periods[1].to).to eq(Date.new(2015, 9, 15))

        expect(predicted_periods[2].from).to eq(Date.new(2015, 9, 27))
        expect(predicted_periods[2].to).to eq(Date.new(2015, 9, 29))
      end
    end


    describe 'creating notifications' do
      describe 'when there are to predict something' do
        before do
          user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
        end

        it 'should call rebuilding notifications for user' do
          expect(notification_builder).to receive(:rebuild_for).with(user).once
          predictor.refresh_for(user)
        end
      end

      describe 'when there are nothing to predict' do
        it 'should not even call rebuilding notifications' do
          expect(notification_builder).not_to receive(:rebuild_for)
          predictor.refresh_for(user)
        end
      end
    end
  end
end