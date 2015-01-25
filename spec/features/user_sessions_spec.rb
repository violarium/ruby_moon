require 'rails_helper'

describe 'User sessions' do

  let!(:existing_user) { User.create!(email: 'example@email.net', password: '123456') }

  it 'checking sign in page' do
    visit '/sign_in'
    expect(page).to have_title('Sign in')
  end

  it 'sign in with invalid credentials' do
    sign_in_with('invalid@email.net', 'invalid password')
    expect(page).to have_content 'Invalid e-mail or password'
    expect(page).to have_title('Sign in')
    expect(page).to have_field('E-mail', with: 'invalid@email.net')
  end

  it 'sign in with valid credentials' do
    sign_in_with('example@email.net', '123456')
    expect(page).not_to have_title('Sign in')
    expect(page).to have_link('Sign out')
  end

  it 'sign in page when already signed in' do
    sign_in_with('example@email.net', '123456')
    visit '/sign_in'
    expect(page).not_to have_title('Sign in')
  end

  it 'should sign out correctly when signed in' do
    sign_in_with('example@email.net', '123456')
    click_link 'Sign out'
    expect(page).not_to have_link('Sign out')
  end
end