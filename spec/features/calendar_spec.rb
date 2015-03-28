require 'rails_helper'

describe 'Calendar page' do
  let(:user) { FactoryGirl.create(:user, password: 'password') }
  before { sign_in_with(user.email, 'password') }



  describe 'when we are not signed in' do
    before do
      sign_out_if_signed_in
      visit '/calendar/2015/1'
    end

    it 'should show sign in page if we are not signed in with error message' do
      expect(page).to have_title('Sign in')
      expect(page).to have_content('You are to sign in!')
    end
  end


  it 'should have title and header with received date' do
    visit '/calendar/2015/1'
    expect(page).to have_title('January, 2015')
    expect(page).to have_selector('h1', text: 'January, 2015')
  end


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

  it 'should open day info page when we click on day' do
    visit '/calendar/2015/2'
    find('.month-days-grid .day > a', text: 10).click

    expect(page).to have_title('10 February, 2015')
    expect(page).to have_selector('h1', '10 February, 2015')
  end



  describe 'when we click on empty day' do

    it 'should show as a message that we are going to add new period' do
      visit '/calendar/2015/2'
      find('.month-days-grid .day > a', text: 10).click

      expect(page).to have_text('You are able to add a new critical period')
    end

    describe 'when we check "Critical day" and click "Save"' do
      it 'should add calendar period with 1 day by default' do
        visit '/calendar/2015/2'
        find('.month-days-grid .day > a', text: 10).click
        check 'Critical day'
        click_on('Save')

        added_period = user.critical_periods.first
        expect(added_period.from).to eq Date.new(2015, 2, 10)
        expect(added_period.to).to eq Date.new(2015, 2, 10)
        expect(page).to have_selector('.day.critical', text: 10)
      end
    end
  end


  describe 'when we click on a day, which belongs to critical period' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 15))
      visit '/calendar/2015/1'
      find('.month-days-grid .day > a', text: 11).click
    end

    it 'should show us a message that this is existing period' do
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
        choose 'Delete current and tail'
        click_on 'Save'

        period = user.reload.critical_periods.first
        expect(period.from).to eq Date.new(2015, 1, 10)
        expect(period.to).to eq Date.new(2015, 1, 10)
      end

      it 'should delete the head if we select this' do
        choose 'Delete current and head'
        click_on 'Save'

        period = user.reload.critical_periods.first
        expect(period.from).to eq Date.new(2015, 1, 12)
        expect(period.to).to eq Date.new(2015, 1, 15)
      end
    end
  end


  describe 'when we click on day, which is near by another period' do
    before do
      user.critical_periods.create!(from: Date.new(2015, 1, 10), to: Date.new(2015, 1, 15))
      visit '/calendar/2015/1'
      find('.month-days-grid .day > a', text: 17).click
    end

    it 'should show us a message that we can add this day to existing period' do
      expect(page).to have_text('You are able to add this day to period 10 January, 2015 - 15 January, 2015')
    end

    it 'should have "critical day" unchecked' do
      checkbox = find(:checkbox, 'Critical day')
      expect(checkbox).not_to be_checked
    end

    describe 'when we check "Critical day" and click "Save"' do
      it 'should add this day and all days between to critical period' do
        check 'Critical day'
        click_on 'Save'

        period = user.reload.critical_periods.first
        expect(period.from).to eq Date.new(2015, 1, 10)
        expect(period.to).to eq Date.new(2015, 1, 17)
      end
    end
  end
end