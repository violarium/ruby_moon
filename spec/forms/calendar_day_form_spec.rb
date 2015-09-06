require 'rails_helper'

describe CalendarDayForm do
  let(:user) { FactoryGirl.create(:user) }
  let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 7)) }


  describe 'special setters and getters conversion' do
    describe '#critical_day' do
      it 'should make 1 string truthy' do
        form.critical_day = '1'
        expect(form.critical_day).to be_truthy
      end

      it 'should make 0 string falsey' do
        form.critical_day = '0'
        expect(form.critical_day).to be_falsey
      end
    end

    describe '#period_length' do
      it 'should convert string to integer' do
        form.period_length = '10'
        expect(form.period_length).to eq 10
      end
    end
  end


  describe 'when received date does not belong to any critical period' do

    it 'should have parameter "critical_day" falsey' do
      expect(form.critical_day).to be_falsey
    end

    describe 'when receive "critical_day" parameter' do
      before { form.critical_day = true }

      describe 'when do not receive period length' do
        it 'should create new critical period with length 1 on submit' do
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 7))
          expect(critical_period.to).to eq(Date.new(2015, 1, 7))
        end

        it 'should be valid' do
          expect(form).to be_valid
        end
      end

      describe 'when receive specified period length' do
        before { form.period_length = 2 }

        it 'should create new critical period with specified length on submit' do
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 7))
          expect(critical_period.to).to eq(Date.new(2015, 1, 8))
        end

        it 'should be valid' do
          expect(form).to be_valid
        end
      end

      describe 'when received length makes new critical period incorrect' do
        before { form.period_length = 8 }
        before { user.critical_periods.create(from: Date.new(2015, 1, 15), to: Date.new(2015, 1, 18)) }

        it 'should not be valid' do
          expect(form).not_to be_valid
        end

        it 'should not create new critical period' do
          expect { form.submit }.not_to change { user.critical_periods.count }
        end
      end
    end

    describe 'when do not receive "critical_day" parameter' do
      it 'should not create critical period on submit' do
        expect { form.submit }.not_to change { user.critical_periods.count }
      end

      it 'should be valid' do
        expect(form).to be_valid
      end
    end
  end


  describe 'when received date belongs to critical period' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10))
      user.reload
    end

    it 'should have parameter "critical_day" truthy' do
      expect(form.critical_day).to be_truthy
    end

    describe 'when receive disabled "critical_day"' do
      before { form.critical_day = false }

      describe 'when delete method not received' do
        it 'should delete existing critical period on submit' do
          expect { form.submit }.to change { user.critical_periods.count }.from(1).to(0)
        end
      end


      describe 'when receive delete method "tail"' do
        before { form.delete_period = 'tail' }

        it 'should delete period days from current date to end' do
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 5))
          expect(critical_period.to).to eq(Date.new(2015, 1, 6))
        end

        it 'should delete period days from current date to end and leave 1 if it is a second day' do
          user.critical_periods.first.update_attributes(from: Date.new(2015, 1, 6))
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 6))
          expect(critical_period.to).to eq(Date.new(2015, 1, 6))
        end

        describe 'if period has length 1' do
          before do
            user.critical_periods.first.update_attributes(from: Date.new(2015, 1, 7), to: Date.new(2015, 1, 7))
          end

          it 'should delete period' do
            expect { form.submit }.to change { user.critical_periods.count }.by(-1)
          end
        end
      end

      describe 'when receive delete method "head"' do
        before { form.delete_period = 'head' }

        it 'should delete period days from head to current date' do
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 8))
          expect(critical_period.to).to eq(Date.new(2015, 1, 10))
        end

        it 'should delete period days from head to current date and leave 1 if it is a pre last day' do
          user.critical_periods.first.update_attributes(to: Date.new(2015, 1, 8))
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 8))
          expect(critical_period.to).to eq(Date.new(2015, 1, 8))
        end
      end

      describe 'if period has length 1' do
        before do
          user.critical_periods.first.update_attributes(from: Date.new(2015, 1, 7), to: Date.new(2015, 1, 7))
        end

        it 'should delete period' do
          expect { form.submit }.to change { user.critical_periods.count }.by(-1)
        end
      end
    end
  end


  describe 'when received date close enough to existing period' do

    describe 'after period' do
      let!(:period) { user.critical_periods.create!(from: Date.new(2015, 1, 2), to: Date.new(2015, 1, 3)) }

      it 'should have parameter "critical_day" falsey' do
        expect(form.critical_day).to be_falsey
      end

      describe 'when receive "critical_day" parameter' do
        before { form.critical_day = true }

        it 'extend existing critical period' do
          form.submit
          period.reload
          expect(period.from).to eq Date.new(2015, 1, 2)
          expect(period.to).to eq Date.new(2015, 1, 7)
        end
      end
    end

    describe 'before period' do
      let!(:period) { user.critical_periods.create!(from: Date.new(2015, 1, 9), to: Date.new(2015, 1, 10)) }

      it 'should have parameter "critical_day" falsey' do
        expect(form.critical_day).to be_falsey
      end

      describe 'when receive "critical_day" parameter' do
        before { form.critical_day = true }

        it 'extend existing critical period' do
          form.submit
          period.reload
          expect(period.from).to eq Date.new(2015, 1, 7)
          expect(period.to).to eq Date.new(2015, 1, 10)
        end
      end
    end
  end
end