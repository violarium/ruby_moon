require 'rails_helper'

describe 'Calendar page' do

  describe 'when we are not signed in' do
    before { visit '/calendar/2015/01' }

    it 'should show sign in page if we are not signed in with error message' do
      expect(page).to have_title('Sign in')
      expect(page).to have_content('You are to sign in!')
    end
  end



  it 'should have title with received date' do
    we_are_signed_in_user
    visit '/calendar/2015/01'

    expect(page).to have_title('January, 2015')
  end

  it 'should show 2 month with they days when we are signed in' do
    we_are_signed_in_user
    visit '/calendar/2015/01'

    expect(page).to have_content('January, 2015')
    expect(page).to have_content('February, 2015')
  end

  it 'should show critical periods of current user' do
    user = we_are_signed_in_user
    user.critical_periods.create!(from: Date.new(2015, 1, 30), to: Date.new(2015, 2, 3))
    user.critical_periods.create!(from: Date.new(2015, 2, 28), to: Date.new(2015, 3, 4))
    user.critical_periods.create!(from: Date.new(2016, 1, 1), to: Date.new(2016, 1, 5))
    visit '/calendar/2015/2'

    date_array = (Date.new(2015, 1, 30) .. Date.new(2015, 2, 3)).to_a  + (Date.new(2015, 2, 28) .. Date.new(2015, 3, 4)).to_a
    date_array.each do |date|
      expect(page).to have_selector('.day.critical', text: date.day)
    end
  end

  it 'should open day info page when we click on day' do
    we_are_signed_in_user
    visit '/calendar/2015/2'
    find('.month-list > li:first-child .day > a', text: 10).click

    expect(page).to have_title('10 February, 2015')
    expect(page).to have_selector('h1', '10 February, 2015')
  end
end