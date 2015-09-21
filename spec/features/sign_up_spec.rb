require 'rails_helper'

describe 'Sign up' do
  it 'should show sign up page when I visit sign_up' do
    visit '/sign_up'
    expect(page).to have_title('Sign up')
  end

  it 'should not show sign up page I singed in and I try to sign up again' do
    FactoryGirl.create(:user, email: 'example@email.net', password: '123456', password_confirmation: '123456')
    sign_in_with('example@email.net', '123456')
    visit '/sign_up'
    expect(page).not_to have_title('Sign up')
  end

  it 'should show sign up page when I click sign up on home page' do
    visit '/'
    click_link 'Sign up'
    expect(page).to have_title('Sign up')
  end


  describe 'when we fill form correctly' do
    before do
      visit '/sign_up'
      fill_in 'E-mail', with: 'example@email.com'
      fill_in 'Password', with: '123456'
      fill_in 'Password confirmation', with: '123456'
    end

    it 'should create new user with received data' do
      expect { click_button 'Sign up' }.to change { User.count }.by(1)
      expect(User.first.email).to eq 'example@email.com'
    end

    it 'should sign up us' do
      click_button 'Sign up'
      expect(page).to have_link('Profile')
    end
  end

  describe 'when we fill form incorrectly' do
    before do
      visit '/sign_up'
      fill_in 'E-mail', with: 'test'
    end

    it 'should show error on sign up page' do
      click_button 'Sign up'
      expect(page).to have_title('Sign up')
      expect(page).to have_content('Please, fill the form correctly')
    end

    it 'should not create user' do
      expect { click_button 'Sign up' }.not_to change { User.count }
    end
  end
end