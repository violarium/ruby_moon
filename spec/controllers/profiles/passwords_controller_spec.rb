require 'rails_helper'

describe Profiles::PasswordsController do
  describe 'GET #edit' do
    include_examples 'controller sign in required' do
      before { get :edit }
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      it 'should render "edit" template' do
        get :edit
        expect(response).to render_template(:edit)
      end

      it 'should pass to view password form for current' do
        password_form = double('password_form')
        expect(PasswordForm).to receive(:new).with(@user).and_return(password_form)
        get :edit
        expect(assigns[:password_form]).to eq password_form
      end
    end
  end

  describe 'PUT #update' do
    include_examples 'controller sign in required' do
      before { put :update }
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      it 'should submit the password form with received data' do
        password_form_data = { current_password: '1', new_password: '1', new_password_confirmation: '1' }
        password_form = double('password_form')

        expect(PasswordForm).to receive(:new).with(@user, password_form_data).and_return(password_form)
        expect(password_form).to receive(:submit)

        put :update, password_form: password_form_data
      end

      describe 'when data is valid' do
        it 'should redirect to #edit' do
          password_form = double('password_form')
          expect(PasswordForm).to receive(:new).and_return(password_form)
          expect(password_form).to receive(:submit).and_return(true)
          put :update, password_form: { data: 'test' }
          expect(response).to redirect_to(profile_password_url)
        end
      end

      describe 'when data is not valid' do
        let(:password_form) { double('password_form') }

        before do
          expect(PasswordForm).to receive(:new).and_return(password_form)
          expect(password_form).to receive(:submit).and_return(false)
          put :update, password_form: { data: 'test' }
        end

        it 'should render "edit" template' do
          expect(response).to render_template(:edit)
        end

        it 'should pass to template password form object' do
          expect(assigns[:password_form]).to eq password_form
        end
      end
    end
  end
end