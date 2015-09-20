require 'rails_helper'

describe UserSettingsController do
  describe 'GET #edit_profile' do
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        get :edit_profile
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      it 'should render "edit_profile" template' do
        get :edit_profile
        expect(response).to render_template(:edit_profile)
      end

      it 'should pass to view current user' do
        get :edit_profile
        expect(assigns[:user]).to eq @user
      end
    end
  end

  describe 'PUT #update_profile' do
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        put :update_profile
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      describe 'when data is valid' do
        it 'should redirect to #edit_profile' do
          expect(@user).to receive(:update_attributes).and_return true
          put :update_profile, user: { email: 'example@email.com' }
          expect(response).to redirect_to(edit_profile_settings_url)
        end

        it 'should update user with received arguments' do
          expect(@user).to receive(:update_attributes).with(email: 'example@email.com',
                                                            time_zone: 'Sydney').and_return true
          put :update_profile, user: { email: 'example@email.com', time_zone: 'Sydney' }
          expect(response).to redirect_to(edit_profile_settings_url)
        end
      end

      describe 'when data is not valid' do
        it 'should render "edit_profile" template' do
          expect(@user).to receive(:update_attributes).and_return false
          put :update_profile, user: { email: 'example@email.com' }
          expect(response).to render_template(:edit_profile)
        end
      end
    end
  end
end