require 'rails_helper'

describe 'Critical periods' do
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
end