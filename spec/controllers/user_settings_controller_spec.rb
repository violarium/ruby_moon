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
        it 'should redirect to #edit_profile with success flash message' do
          expect(@user).to receive(:update_attributes).and_return true
          put :update_profile, user: { email: 'example@email.com' }
          expect(response).to redirect_to(edit_profile_settings_url)
          expect(flash[:success]).not_to be_nil
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


  describe 'GET #edit_password' do
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        get :edit_password
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      it 'should render "edit_password" template' do
        get :edit_password
        expect(response).to render_template(:edit_password)
      end

      it 'should pass to view password form for current' do
        password_form = double('password_form')
        expect(PasswordForm).to receive(:new).with(@user).and_return(password_form)
        get :edit_password
        expect(assigns[:password_form]).to eq password_form
      end
    end
  end

  describe 'PUT #update_password' do
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        put :update_password
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      it 'should submit the password form with received data' do
        password_form_data = { current_password: '1', new_password: '1', new_password_confirmation: '1' }
        password_form = double('password_form')

        expect(PasswordForm).to receive(:new).with(@user, password_form_data).and_return(password_form)
        expect(password_form).to receive(:submit)

        put :update_password, password_form: password_form_data
      end

      describe 'when data is valid' do
        it 'should redirect to #edit_password' do
          password_form = double('password_form')
          expect(PasswordForm).to receive(:new).and_return(password_form)
          expect(password_form).to receive(:submit).and_return(true)
          put :update_password, password_form: { data: 'test' }
          expect(response).to redirect_to(edit_password_settings_url)
        end
      end

      describe 'when data is not valid' do
        let(:password_form) { double('password_form') }

        before do
          expect(PasswordForm).to receive(:new).and_return(password_form)
          expect(password_form).to receive(:submit).and_return(false)
          put :update_password, password_form: { data: 'test' }
        end

        it 'should render "edit_password" template' do
          expect(response).to render_template(:edit_password)
        end

        it 'should pass to template password form object' do
          expect(assigns[:password_form]).to eq password_form
        end
      end
    end
  end
end