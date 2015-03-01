require 'rails_helper'

describe CalendarDayForm do
  let(:user) { FactoryGirl.create(:user) }


  describe 'form accessors' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: 1,
                                                                   period_length: 1,
                                                                   delete_period: 'all' }) }
    it 'should respond to #critical_day with received data' do
      expect(form.critical_day).to eq 1
    end

    it 'should respond to #period_length with received data' do
      expect(form.period_length).to eq 1
    end

    it 'should respond to #delete_period with received data' do
      expect(form.delete_period).to eq 'all'
    end
  end


  describe 'when received date does not belong to any critical period' do

    describe 'when receive "critical_day" parameter' do

      describe 'when do not receive period length' do
        let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: 1 }) }

        it 'should create new critical period with length 1 on submit' do
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 1))
          expect(critical_period.to).to eq(Date.new(2015, 1, 1))
        end

        it 'should be valid' do
          expect(form).to be_valid
        end
      end

      describe 'when receive specified period length' do
        let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: 1, period_length: 2 }) }

        it 'should create new critical period with specified length on submit' do
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 1))
          expect(critical_period.to).to eq(Date.new(2015, 1, 2))
        end

        it 'should be valid' do
          expect(form).to be_valid
        end
      end

      describe 'when received length makes new critical period incorrect' do
        let(:form) { CalendarDayForm.new(user, Date.new(2015, 2, 1), { critical_day: 1, period_length: 8 }) }

        before { user.critical_periods.create(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 15)) }

        it 'should not be valid' do
          expect(form).not_to be_valid
        end

        it 'should not create new critical period' do
          expect { form.submit }.not_to change { user.critical_periods.count }
        end
      end
    end

    describe 'when do not receive "critical_day"' do
      let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 1)) }

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

    it 'should have parameter :critical_day to be 1' do
      form = CalendarDayForm.new(user, Date.new(2015, 1, 6))
      expect(form.critical_day).to eq 1
    end

    describe 'when receive disabled "critical_day"' do

      describe 'when receive delete method "all"' do
        it 'should delete existing critical period on submit' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 6), { critical_day: 0, delete_period: 'all' })
          expect { form.submit }.to change { user.critical_periods.count }.from(1).to(0)
        end

        describe 'when receive "critical_day"' do
          it 'should not delete critical period' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 6), { delete_period: 'all', critical_day: 1 })
            expect { form.submit }.not_to change { user.critical_periods.count }
          end
        end
      end


      describe 'when receive delete method "tail"' do
        it 'should delete period days from current date to end' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 7), { critical_day: 0, delete_period: 'tail' })
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 5))
          expect(critical_period.to).to eq(Date.new(2015, 1, 6))
        end

        it 'should delete period days and leave 1 if it is a case' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 6), { critical_day: 0, delete_period: 'tail' })
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 5))
          expect(critical_period.to).to eq(Date.new(2015, 1, 5))
        end

        it 'should delete period if it has length 1' do
          user.critical_periods.create!(from: Date.new(2015, 10, 1), to: Date.new(2015, 10, 1))
          form = CalendarDayForm.new(user, Date.new(2015, 10, 1), { critical_day: 0, delete_period: 'tail' })
          expect { form.submit }.to change { user.critical_periods.count }.by(-1)
        end

        describe 'when receive "critical_day"' do
          it 'should do nothing with critical period' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 7), { delete_period: 'tail', critical_day: 1 })
            form.submit

            critical_period = user.critical_periods.first
            expect(critical_period.from).to eq(Date.new(2015, 1, 5))
            expect(critical_period.to).to eq(Date.new(2015, 1, 10))
          end
        end
      end


      describe 'when receive delete method "head"' do

        it 'should delete period days from head to current date' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 8), { critical_day: 0, delete_period: 'head' })
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 9))
          expect(critical_period.to).to eq(Date.new(2015, 1, 10))
        end

        it 'should delete period days and leave 1 if it is a case' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 9), { critical_day: 0, delete_period: 'head' })
          expect { form.submit }.not_to change { user.critical_periods.count }

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 10))
          expect(critical_period.to).to eq(Date.new(2015, 1, 10))
        end

        it 'should delete period if it has length 1' do
          user.critical_periods.create!(from: Date.new(2015, 10, 1), to: Date.new(2015, 10, 1))
          form = CalendarDayForm.new(user, Date.new(2015, 10, 1), { critical_day: 0, delete_period: 'head' })
          expect { form.submit }.to change { user.critical_periods.count }.by(-1)
        end

        describe 'when receive "critical_day"' do
          it 'should do nothing with critical period' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 8), { delete_period: 'head', critical_day: 1 })
            form.submit

            critical_period = user.critical_periods.first
            expect(critical_period.from).to eq(Date.new(2015, 1, 5))
            expect(critical_period.to).to eq(Date.new(2015, 1, 10))
          end
        end
      end
    end
  end
end