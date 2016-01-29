require 'rails_helper'

describe PeriodPredictor do
  describe '#refresh_for' do
    let(:user) { FactoryGirl.create(:user) }
    let(:predictor) { PeriodPredictor.new(NotificationBuilder.new, 28, 4, 1) }

    describe 'when there are no critical periods' do
      it 'does not predict any periods' do
        expect { predictor.refresh_for(user) }.not_to change { user.future_critical_periods.count }
      end

      it 'clears existing predicted periods' do
        user.future_critical_periods.create!(from: Date.new(2014, 1, 1), to: Date.new(2014, 1, 3))
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.to(0)
      end

      it 'returns false' do
        expect(predictor.refresh_for(user)).to eq false
      end
    end


    describe 'when there is one critical period' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
      end

      it 'predicts period with default interval and same length' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(1)
        predicted_period = user.future_critical_periods.first

        expect(predicted_period[:from]).to eq(Date.new(2015, 1, 29))
        expect(predicted_period[:to]).to eq(Date.new(2015, 2, 1))
      end

      it 'returns true' do
        expect(predictor.refresh_for(user)).to eq true
      end

      it 'calls notification builder to rebuild notifications for user' do
        notify_builder = double(NotificationBuilder)

        predictor = PeriodPredictor.new(notify_builder, 28, 4, 1)
        expect(notify_builder).to receive(:rebuild_for).with(user)

        predictor.refresh_for(user)
      end
    end


    describe 'when there are 2 critical periods' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 8, 2), to: Date.new(2015, 8, 3))
        user.critical_periods.create!(from: Date.new(2015, 8, 16), to: Date.new(2015, 8, 19))
      end

      it 'predicts period with average data according to this 2 periods' do
        expect { predictor.refresh_for(user) }.to change { user.future_critical_periods.count }.by(1)
        predicted_period = user.future_critical_periods.first

        expect(predicted_period.from).to eq(Date.new(2015, 8, 30))
        expect(predicted_period.to).to eq(Date.new(2015, 9, 1))
      end
    end


    describe 'when there are 5 critical periods' do
      before do
        user.critical_periods.create!(from: Date.new(2014, 12, 5), to: Date.new(2014, 12, 20)) # long period
        user.critical_periods.create!(from: Date.new(2015, 1, 1), to: Date.new(2015, 1, 4))
        user.critical_periods.create!(from: Date.new(2015, 1, 21), to: Date.new(2015, 1, 25))
        user.critical_periods.create!(from: Date.new(2015, 2, 12), to: Date.new(2015, 2, 14))
        user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 4))
      end

      it 'predicts period with average data according to last 4 periods' do
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

      it 'removes old predicted period' do
        expect { predictor.refresh_for(user) }.not_to change { user.future_critical_periods.count }
        predicted_period = user.future_critical_periods.first

        expect(predicted_period.from).not_to eq(old_predicted.from)
        expect(predicted_period.to).not_to eq(old_predicted.to)
      end

      it 'does not recreate predicted periods if it has same parameters' do
        existing_predicted = user.future_critical_periods.create!(from: Date.new(2015, 1, 29), to: Date.new(2015, 2, 1))
        predictor.refresh_for(user)
        expect(user.reload.future_critical_periods.first.id).to eq existing_predicted.id
      end

      it 'does not remove predicted periods from different user' do
        another_user = FactoryGirl.create(:user, email: 'another@email.org')
        another_user.future_critical_periods.create!(from: Date.new(2014, 1, 1), to: Date.new(2014, 1, 3))

        expect { predictor.refresh_for(another_user) }.not_to change { user.future_critical_periods.count }
      end
    end


    describe 'when we want to predict 3 periods' do
      let(:predictor) { PeriodPredictor.new(NotificationBuilder.new, 28, 4, 3) }

      before do
        user.critical_periods.create!(from: Date.new(2015, 8, 2), to: Date.new(2015, 8, 3))
        user.critical_periods.create!(from: Date.new(2015, 8, 16), to: Date.new(2015, 8, 19))
      end

      it 'predicts 3 periods' do
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
  end
end