require 'rails_helper'

describe 'Calendar' do

  it 'should show 2 month with they days' do
    visit '/calendar/2015/01'
    expect(page).to have_content('January, 2015')
    expect(page).to have_content('February, 2015')
  end
end