require 'rails_helper'

describe 'Calendar page' do
  let(:user) { FactoryGirl.create(:user, password: 'password') }
  before { sign_in_with(user.email, 'password') }


  describe 'general behaviour' do
    describe 'when we are not signed in' do
      before do
        sign_out_if_signed_in
        visit '/calendar/2015/1'
      end

      include_examples 'sign in required'
    end


    it 'should have title and header for received month' do
      visit '/calendar/2015/1'
      expect(page).to have_title('January, 2015')
      expect(page).to have_selector('h1', text: 'January, 2015')
    end

    it 'should open day info page when we click on day' do
      visit '/calendar/2015/2'
      find('.month-days-grid .day > a', text: 10).click

      expect(page).to have_title('10 February, 2015')
      expect(page).to have_selector('h1', '10 February, 2015')
    end
  end


  describe 'critical periods' do
    it 'should show critical periods for current user' do
      user.critical_periods.create!(from: Date.new(2015, 1, 30), to: Date.new(2015, 2, 3))
      user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 4))
      user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))
      visit '/calendar/2015/2'

      date_array = (Date.new(2015, 1, 30) .. Date.new(2015, 2, 3)).to_a  + (Date.new(2015, 2, 28) .. Date.new(2015, 3, 4)).to_a
      date_array.each do |date|
        expect(page).to have_selector('.day.critical', text: date.day)
      end

      expect(page.all('.day.critical').count).to eq date_array.count
    end


    describe 'when we click an empty day' do
      before do
        visit '/calendar/2015/2'
        find('.month-days-grid .day > a', text: 10).click
      end


      it 'should show a message that we are going to add new period' do
        expect(page).to have_text('You are able to add a new critical period')
      end

      describe 'when we check "Critical day" and click "Save"' do
        before do
          check 'Critical day'
          click_on('Save')
        end

        it 'should add calendar period with 1 day length' do
          added_period = user.critical_periods.first
          expect(added_period.from).to eq Date.new(2015, 2, 10)
          expect(added_period.to).to eq Date.new(2015, 2, 10)
          expect(page).to have_selector('.day.critical', text: 10)
        end
      end
    end


    describe 'when we click a day, which belongs to critical period' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 15))
        visit '/calendar/2015/1'
        find('.month-days-grid .day > a', text: 11).click
      end

      it 'should show a message that this is existing period' do
        expect(page).to have_text('This day belongs to period 10 January, 2015 - 15 January, 2015')
      end

      it 'should have "critical day" checked' do
        checkbox = find(:checkbox, 'Critical day')
        expect(checkbox).to be_checked
      end

      describe 'when we uncheck critical day' do
        before { uncheck 'Critical day' }

        it 'should delete whole period if we select this' do
          choose 'Delete whole period'
          click_on 'Save'
          expect(user.critical_periods.count).to eq 0
        end

        it 'should delete the tail if we select this' do
          choose 'Remove current date and period tail'
          click_on 'Save'

          period = user.reload.critical_periods.first
          expect(period.from).to eq Date.new(2015, 1, 10)
          expect(period.to).to eq Date.new(2015, 1, 10)
        end

        it 'should delete the head if we select this' do
          choose 'Remove current date and period head'
          click_on 'Save'

          period = user.reload.critical_periods.first
          expect(period.from).to eq Date.new(2015, 1, 12)
          expect(period.to).to eq Date.new(2015, 1, 15)
        end
      end
    end


    describe 'when we click day, which is near by another period' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 15))
        visit '/calendar/2015/1'
        find('.month-days-grid .day > a', text: 17).click
      end

      it 'should show a message that we can add this day to existing period' do
        expect(page).to have_text('You are able to add this day to period 10 January, 2015 - 15 January, 2015')
      end

      it 'should have "critical day" unchecked' do
        checkbox = find(:checkbox, 'Critical day')
        expect(checkbox).not_to be_checked
      end

      describe 'when we check "Critical day" and click "Save"' do
        before do
          check 'Critical day'
          click_on 'Save'
        end

        it 'should add this day and all days between to critical period' do
          period = user.reload.critical_periods.first
          expect(period.from).to eq Date.new(2015, 1, 10)
          expect(period.to).to eq Date.new(2015, 1, 17)
        end
      end
    end


    describe 'when we click day, which is near between 2 periods' do
      before do
        user.critical_periods.create!(from: Date.new(2015, 8, 2), to: Date.new(2015, 8, 3))
        user.critical_periods.create!(from: Date.new(2015, 8, 16), to: Date.new(2015, 8, 19))
        visit '/calendar/2015/8'
        find('.month-days-grid .day > a', text: /^9$/).click
      end

      it 'should show us a message, that we can not add this day to any of 2 periods' do
        expect(page).to have_text('This day is too close to more than one period: ' +
                                      '2 August, 2015 - 3 August, 2015 16 August, 2015 - 19 August, 2015')
        expect(page).to have_text('You are not able to add this day to any of them')
      end

      it 'should have "critical day" uncheked and disabled' do
        checkbox = find(:checkbox, 'Critical day', disabled: true)
        expect(checkbox).not_to be_checked
        expect(checkbox).to be_disabled
      end

      it 'should do nothing when we submit form' do
        click_on 'Save'

        periods = user.critical_periods.all.to_a
        expect(periods[0].from).to eq(Date.new(2015, 8, 2))
        expect(periods[0].to).to eq(Date.new(2015, 8, 3))
        expect(periods[1].from).to eq(Date.new(2015, 8, 16))
        expect(periods[1].to).to eq(Date.new(2015, 8, 19))
      end
    end


    describe 'when we try to create critical period between other ones to close' do
      before do
        visit '/calendar/day/2016/1/13'
        user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 8))
        user.critical_periods.create!(from: Date.new(2016, 1, 20), to: Date.new(2016, 1, 20))
        check 'Critical day'
        click_on 'Save'
      end

      it 'should show same day page' do
        expect(page).to have_title('13 January, 2016')
      end

      it 'should show message about errors' do
        expect(page).to have_content('There are errors')
      end
    end
  end


  describe 'predicted critical periods' do
    it 'should show predicted critical periods for user' do
      user.future_critical_periods.create!(from: Date.new(2015, 1, 30), to: Date.new(2015, 2, 3))
      user.future_critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 4))
      user.future_critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))
      visit '/calendar/2015/2'

      date_array = (Date.new(2015, 1, 30) .. Date.new(2015, 2, 3)).to_a  + (Date.new(2015, 2, 28) .. Date.new(2015, 3, 4)).to_a
      date_array.each do |date|
        expect(page).to have_selector('.day.future-critical', text: date.day)
      end

      expect(page.all('.day.future-critical').count).to eq date_array.count
    end

    it 'should tell us about upcoming critical period' do
      today = user.in_time_zone(Time.now).to_date
      future = user.future_critical_periods.create!(from: today + 4.days, to: today + 4.days + 2.days)
      visit '/calendar/2015/2'

      expect(page).to have_content('Upcoming critical period: ' +
                                       I18n.l(future.from, format: :full_day) + ' - ' +
                                       I18n.l(future.to, format: :full_day))
      expect(page).to have_content('Days left: 4')
    end

    it 'should tell us about upcoming critical period even when we view another date at all' do
      today = user.in_time_zone(Time.now).to_date
      future = user.future_critical_periods.create!(from: today + 4.days, to: today + 4.days + 2.days)
      visit '/calendar/2200/2'

      expect(page).to have_content('Upcoming critical period: ' +
                                       I18n.l(future.from, format: :full_day) + ' - ' +
                                       I18n.l(future.to, format: :full_day))
      expect(page).to have_content('Days left: 4')
    end

    describe 'prediction' do
      describe 'when I create critical period' do
        before do
          visit '/calendar/2015/2'
          find('.month-days-grid .day > a', text: 10).click
          check 'Critical day'
          click_on 'Save'
        end

        it 'should create predicted critical periods' do
          expect(user.future_critical_periods.count).to eq 3

          future_critical_period = user.future_critical_periods.first
          expect(future_critical_period.from).to eq(Date.new(2015, 2, 10) + 28.days)
          expect(future_critical_period.to).to eq(Date.new(2015, 2, 10) + 28.days)
        end
      end

      it 'should remove all predicted critical periods when I delete last critical period' do
        user.critical_periods.create!(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 10))
        user.future_critical_periods.create!(from: Date.new(2015, 1, 30), to: Date.new(2015, 2, 3))

        visit '/calendar/2015/2'
        find('.month-days-grid .day > a', text: 10).click
        uncheck 'Critical day'
        choose 'Delete whole period'
        click_on 'Save'

        expect(user.future_critical_periods.count).to eq 0
      end


      describe 'when I change existing critical period' do
        before do
          user.critical_periods.create!(from: Date.new(2015, 2, 10), to: Date.new(2015, 2, 10))
          user.future_critical_periods.create!(from: Date.new(2015, 2, 10) + 28.days, to: Date.new(2015, 2, 10) + 28.days)

          visit '/calendar/2015/2'
          find('.month-days-grid .day > a', text: 11).click
          check 'Critical day'
          click_on 'Save'
        end

        it 'should update predicted critical periods' do
          expect(user.future_critical_periods.count).to eq(3)

          future_critical_period = user.future_critical_periods.first
          expect(future_critical_period.from).to eq(Date.new(2015, 2, 10) + 28.days)
          expect(future_critical_period.to).to eq(Date.new(2015, 2, 10) + 28.days + 1.day)
        end
      end
    end
  end


  describe 'critical day value' do
    it 'should save critical day value for critical period' do
      visit '/calendar/2015/2'
      find('.month-days-grid .day > a', text: 10).click
      check 'Critical day'
      find('#calendar_day_form_critical_day_value_large').find(:xpath, '..').click
      click_on 'Save'

      critical_day = user.critical_periods.first.critical_day_by_date(Date.new(2015, 2, 10))
      expect(critical_day.value).to eq 'large'
    end
  end
end