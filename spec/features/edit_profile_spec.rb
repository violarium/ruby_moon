require 'rails_helper'

describe 'Profile' do
  let(:user) { FactoryGirl.create(:user, password: 'password') }
  before { sign_in_with(user.email, 'password') }

  describe 'profile page' do
    describe 'when I am not signed in' do
      before do
        sign_out_if_signed_in
        visit '/profile'
      end

      it 'should show sign in page with error message' do
        expect(page).to have_title('Sign in')
        expect(page).to have_content('You are to sign in!')
      end
    end

    it 'should open profile page on click in menu' do
      visit '/'
      click_on 'Profile'
      click_on 'Edit profile'
      expect(page).to have_title('Your profile')
    end

    it 'should show profile page' do
      visit '/profile'
      expect(page).to have_title('Your profile')
    end

    describe 'when form filled in correctly' do
      before do
        visit '/profile'
        fill_in 'E-mail', with: 'example@email.com'
        select 'Sydney', from: 'Time zone'
        click_button 'Update'
      end

      it 'should show profile form with success message' do
        expect(page).to have_title('Your profile')
        expect(page).to have_content('Your profile updated')
      end

      it 'should update email and timezone' do
        user.reload
        expect(user.email).to eq 'example@email.com'
        expect(user.time_zone).to eq 'Sydney'
      end
    end

    describe 'when form not filled in correctly' do
      before do
        visit '/profile'
        fill_in 'E-mail', with: 'test'
        click_button 'Update'
      end

      it 'should show profile form with error message' do
        expect(page).to have_title('Your profile')
        expect(page).to have_content('Please, fill the form correctly')
      end

      it 'should not update user' do
        user.reload
        expect(user.email).not_to eq 'test'
      end
    end
  end


  describe 'password page' do
    describe 'when I am not signed in' do
      before do
        sign_out_if_signed_in
        visit '/profile/password'
      end

      it 'should show sign in page with error message' do
        expect(page).to have_title('Sign in')
        expect(page).to have_content('You are to sign in!')
      end
    end

    it 'should show password change page' do
      visit '/profile/password'
      expect(page).to have_title('Password change')
    end

    it 'should open password change page on click in menu' do
      visit '/'
      click_on 'Profile'
      click_on 'Change password'
      expect(page).to have_title('Password change')
    end

    describe 'when we fill in current password correctly' do
      before do
        visit '/profile/password'
        fill_in 'Current password', with: 'password'
      end

      describe 'when we type new password and password confirmation correctly' do
        before do
          fill_in 'New password', with: '123456'
          fill_in 'Password confirmation', with: '123456'
          click_button 'Update password'
        end

        it 'should update password' do
          user.reload
          expect(user.password == '123456').to be_truthy
        end

        it 'should show password change form with success message' do
          expect(page).to have_title('Password change')
          expect(page).to have_content('Your password updated')
        end
      end

      describe 'when we type new password and password confirmation incorrectly' do
        before do
          fill_in 'New password', with: '123456'
          fill_in 'Password confirmation', with: '1'
          click_button 'Update password'
        end

        it 'should not update password' do
          user.reload
          expect(user.password).to eq('password')
        end

        it 'should show password change form with error message' do
          expect(page).to have_title('Password change')
          expect(page).to have_content('Please, fill the form correctly')
        end
      end
    end

    describe 'when we fill in current password incorrectly' do
      before do
        visit '/profile/password'
        fill_in 'Current password', with: ''
      end

      describe 'when we type new password and password confirmation correctly' do
        before do
          fill_in 'New password', with: '123456'
          fill_in 'Password confirmation', with: '123456'
          click_button 'Update password'
        end

        it 'should not update password' do
          user.reload
          expect(user.password).to eq('password')
        end

        it 'should show password change form with error message' do
          expect(page).to have_title('Password change')
          expect(page).to have_content('Please, fill the form correctly')
        end
      end
    end
  end
end