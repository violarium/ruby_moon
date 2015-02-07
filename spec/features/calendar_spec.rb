require 'rails_helper'

describe 'Calendar page' do

  describe 'when we are signed in' do
    before do
      we_are_signed_in_user
      visit '/calendar/2015/01'
    end

    it 'should have title with received date' do
      expect(page).to have_title('January, 2015')
    end

    it 'should show 2 month with they days when we are signed in' do
      expect(page).to have_content('January, 2015')
      expect(page).to have_content('February, 2015')
    end
  end


  describe 'when we are not signed in' do
    before { visit '/calendar/2015/01' }

    it 'should show sign in page if we are not signed in with error message' do
      expect(page).to have_title('Sign in')
      expect(page).to have_content('You are to sign in!')
    end
  end
end