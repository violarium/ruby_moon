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

      include_examples 'sign in required'
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
      end

      it 'should show profile form with success message' do
        click_button 'Update'
        expect(page).to have_title('Your profile')
        expect(page).to have_content('Your profile updated')
      end

      it 'should update email and timezone' do
        click_button 'Update'
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

      include_examples 'sign in required'
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


  describe 'notifications page' do
    describe 'when I am not signed in' do
      before do
        sign_out_if_signed_in
        visit '/profile/notifications'
      end

      include_examples 'sign in required'
    end

    it 'should open notifications page by direct link' do
      visit '/profile/notifications'
      expect(page).to have_title('Notifications')
    end

    it 'should open notifications page on click in menu' do
      visit '/'
      click_on 'Profile'
      click_on 'Notifications'
      expect(page).to have_title('Notifications')
    end

    it 'should show current notification settings' do
      user.notify_before = [0, 2]
      user.notify_at = 10
      user.save!
      visit '/profile/notifications'

      expect(page).to have_checked_field('In day')
      expect(page).to have_unchecked_field('Before 1 day')
      expect(page).to have_checked_field('Before 2 days')

      expect(page).to have_field('Notify at', with: 10)
    end

    describe 'when form filled in correctly' do
      before do
        visit '/profile/notifications'
        uncheck 'In day'
        uncheck 'Before 1 day'
        check 'Before 2 days'
        fill_in 'Notify at', with: '3'
      end

      it 'should show notifications page with success message' do
        click_button 'Update notifications'
        expect(page).to have_title('Notifications')
        expect(page).to have_content('Notifications updated')
      end

      it 'should update notification settings' do
        click_button 'Update notifications'
        user.reload
        expect(user.notify_before).to eq [2]
        expect(user.notify_at).to eq 3
      end
    end

    describe 'when form not filled in correctly' do
      before do
        visit '/profile/notifications'
        fill_in 'Notify at', with: '33'
        click_button 'Update notifications'
      end

      it 'should show profile form with error message' do
        expect(page).to have_title('Notifications')
        expect(page).to have_content('Please, fill the form correctly')
      end
    end
  end
end