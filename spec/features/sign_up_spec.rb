require 'rails_helper'

describe 'Sign up' do
  it 'should show sign up page when I visit sign_up' do
    visit '/sign_up'
    expect(page).to have_title('Sign up')
  end

  it 'should not show sign up page I singed in and I try to sign up again' do
    FactoryGirl.create(:user, email: 'example@email.net', password: '123456')
    sign_in_with('example@email.net', '123456')
    visit '/sign_up'
    expect(page).not_to have_title('Sign up')
  end

  it 'should show sign up page when I click sign up on home page' do
    visit '/'
    click_link 'Sign up'
    expect(page).to have_title('Sign up')
  end

  it 'should create new user when we fill form correctly' do

  end

  it 'should show error and not create user when form filled incorrectly' do

  end

  it 'should sign in us automatically when we sign up correctly' do

  end
end