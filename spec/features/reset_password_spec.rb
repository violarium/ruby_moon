require 'rails_helper'

describe 'Reset password' do
  describe 'go to sign in page' do
    it 'should have reset password link' do
      visit '/sign_in'
      click_on 'Forgot your password?'
      expect(page).to have_title('Password reset')
      expect(page).to have_text('Enter your email and follow instructions')
    end
  end

  describe 'sending password email' do
    let!(:existing_user) { FactoryGirl.create(:user,
                                              email: 'example@email.net',
                                              password: '123456',
                                              password_confirmation: '123456') }

    describe 'correct email' do
      before do
        visit '/password-reset'
        fill_in 'E-mail', with: 'example@email.net'
        click_on 'Send instructions'
      end

      it 'should update existing user' do
        existing_user.reload
        expect(existing_user.reset_password_token).not_to be_nil
      end

      it 'should show message' do
        expect(page).to have_text('Instructions to reset your password have been sent to your email')
      end
    end


    describe 'incorrect email' do
      before do
        visit '/password-reset'
        fill_in 'E-mail', with: 'incorrect@email.net'
        click_on 'Send instructions'
      end

      it 'should show an error' do
        expect(page).to have_text('There are no user with such email')
      end
    end
  end


  describe 'reseting password' do
    let!(:existing_user) { FactoryGirl.create(:user,
                                              email: 'example@email.net',
                                              password: '123456',
                                              password_confirmation: '123456',
                                              reset_password_token: 'token',
                                              reset_password_at: Time.now) }

    it 'should show 404 page when token is URL is incorrect' do
      visit '/password-reset/incorrect-token'
      expect(page.status_code).to eq(404)
    end

    it 'should show reset password page when token is correct' do
      visit '/password-reset/token'
      expect(page).to have_text('Enter new password')
    end


    describe 'when we try to change password' do
      before do
        visit '/password-reset/token'
      end

      describe 'when we type new password and password confirmation correctly' do
        before do
          fill_in 'New password', with: 'new_password'
          fill_in 'Password confirmation', with: 'new_password'
          click_button 'Change password'
        end

        it 'should update password' do
          existing_user.reload
          expect(existing_user.password == 'new_password').to be_truthy
        end

        it 'should show sign in form with success message' do
          expect(page).to have_title('Sign in')
          expect(page).to have_content('Your password has been changed')
        end
      end

      describe 'when we type new password and password confirmation incorrectly' do
        before do
          fill_in 'New password', with: 'new_password'
          fill_in 'Password confirmation', with: '1'
          click_button 'Change password'
        end

        it 'should not update password' do
          existing_user.reload
          expect(existing_user.password).to eq('123456')
        end

        it 'should show password change form with error message' do
          expect(page).to have_text('Enter new password')
          expect(page).to have_content('Please, fill the form correctly')
        end
      end
    end
  end
end