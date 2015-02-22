require 'rails_helper'

describe CalendarDayForm do
  # todo: use factory girl
  let(:user) { User.create!(email: 'example@email.net') }


  describe 'form accessors' do
    let(:form) { CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: true,
                                                                   period_length: 1,
                                                                   delete_period: 'all' }) }
    it 'should respond to #critical_day with received data' do
      expect(form.critical_day).to eq true
    end

    it 'should respond to #period_length with received data' do
      expect(form.period_length).to eq 1
    end

    it 'should respond to #delete_period with received data' do
      expect(form.delete_period).to eq 'all'
    end
  end


  describe 'form submit' do

    describe 'when current date does not belong to any critical period' do

      describe 'when receive "critical_day"' do
        it 'should create new critical period with lenth 1' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: true })
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 1))
          expect(critical_period.to).to eq(Date.new(2015, 1, 1))
        end

        it 'should create new critical period with received length' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 1), { critical_day: true, period_length: 2 })
          form.submit

          critical_period = user.critical_periods.first
          expect(critical_period.from).to eq(Date.new(2015, 1, 1))
          expect(critical_period.to).to eq(Date.new(2015, 1, 2))
        end
      end

      describe 'when do not receive "critical_day"' do
        it 'should not create critical period' do
          form = CalendarDayForm.new(user, Date.new(2015, 1, 1))
          form.submit

          expect(user.critical_periods.count).to eq 0
        end
      end
    end


    describe 'when current date belongs to critical period' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 5), to: Date.new(2015, 1, 10))
        user.reload
      end


      describe 'delete_period' do


        describe 'delete all' do
          it 'should delete existing critical period' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 6), { delete_period: CalendarDayForm::Delete::ALL })
            expect { form.submit }.to change { user.critical_periods.count }.from(1).to(0)
          end

          describe 'when receive "critical_day"' do
            it 'should not delete critical period' do
              form = CalendarDayForm.new(user, Date.new(2015, 1, 6), { delete_period: CalendarDayForm::Delete::ALL,
                                                                       critical_day: true })
              expect { form.submit }.not_to change { user.critical_periods.count }
            end
          end
        end


        describe 'delete tail' do
          it 'should delete period days from current to end' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 7), { delete_period: CalendarDayForm::Delete::TAIL })
            expect { form.submit }.not_to change { user.critical_periods.count }

            critical_period = user.critical_periods.first
            expect(critical_period.from).to eq(Date.new(2015, 1, 5))
            expect(critical_period.to).to eq(Date.new(2015, 1, 6))
          end

          it 'should delete period if it has length 1' do
            user.critical_periods.create!(from: Date.new(2015, 10, 1), to: Date.new(2015, 10, 1))
            form = CalendarDayForm.new(user, Date.new(2015, 10, 1), { delete_period: CalendarDayForm::Delete::TAIL })
            expect { form.submit }.to change { user.critical_periods.count }.by(-1)
          end

          describe 'when receive "critical_day"' do
            it 'should do nothing with critical period' do
              form = CalendarDayForm.new(user, Date.new(2015, 1, 7), { delete_period: CalendarDayForm::Delete::TAIL,
                                                                       critical_day: true })
              form.submit

              critical_period = user.critical_periods.first
              expect(critical_period.from).to eq(Date.new(2015, 1, 5))
              expect(critical_period.to).to eq(Date.new(2015, 1, 10))
            end
          end
        end


        describe 'delete head' do

          it 'should delete period days from head to current date' do
            form = CalendarDayForm.new(user, Date.new(2015, 1, 8), { delete_period: CalendarDayForm::Delete::HEAD })
            expect { form.submit }.not_to change { user.critical_periods.count }

            critical_period = user.critical_periods.first
            expect(critical_period.from).to eq(Date.new(2015, 1, 9))
            expect(critical_period.to).to eq(Date.new(2015, 1, 10))
          end

          it 'should delete period if it has length 1' do
            user.critical_periods.create!(from: Date.new(2015, 10, 1), to: Date.new(2015, 10, 1))
            form = CalendarDayForm.new(user, Date.new(2015, 10, 1), { delete_period: CalendarDayForm::Delete::HEAD })
            expect { form.submit }.to change { user.critical_periods.count }.by(-1)
          end

          describe 'when receive "critical_day"' do
            it 'should do nothing with critical period' do
              form = CalendarDayForm.new(user, Date.new(2015, 1, 8), { delete_period: CalendarDayForm::Delete::HEAD,
                                                                       critical_day: true })
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
end