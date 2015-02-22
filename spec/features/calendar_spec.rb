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


  it 'should show as a message that we are going to add new period' do
    we_are_signed_in_user
    visit '/calendar/2015/2'
    find('.month-list > li:first-child .day > a', text: 10).click

    expect(page).to have_text('You are able to add a new critical period')
  end


  # it 'should add calendar period with 1 day by default' do
  #   user = we_are_signed_in_user
  #   visit '/calendar/2015/2'
  #   find('.month-list > li:first-child .day > a', text: 10).click
  #   click_on('Save')
  #
  #   added_period = user.critical_periods.first
  #   expect(added_period.from).to eq Date.new(2015, 2, 10)
  #   expect(added_period.to).to eq Date.new(2015, 2, 10)
  #   # todo: add new page check?
  # end
  #
  # it 'should add calendar period with 3 days if we select that' do
  #   user = we_are_signed_in_user
  #   visit '/calendar/2015/2'
  #   find('.month-list > li:first-child .day > a', text: 10).click
  #   select_option '12 February 2015', from: 'Period end'
  #   click_on('Save')
  #
  #   added_period = user.critical_periods.first
  #   expect(added_period.from).to eq Date.new(2015, 2, 10)
  #   expect(added_period.to).to eq Date.new(2015, 2, 12)
  # end
end