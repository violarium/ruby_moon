require 'rails_helper'

describe PasswordResetsController do
  describe 'GET #new' do
    context 'not signed in user' do
      it 'should render new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'should pass form object into template' do
        form = double('sign_in_form')
        expect(PasswordReset::SendForm).to receive(:new).and_return(form)
        get :new
        expect(assigns(:send_form)).to eq form
      end
    end

    context 'sign in user' do
      before { controller_sign_in }

      it 'should redirect to home page' do
        get :new
        expect(response).to redirect_to home_page_url
      end
    end
  end


  describe 'POST #create' do
    let(:form) { double('send_reset_form') }

    describe 'valid credentials' do
      let(:user) { double('user', id: '100').as_null_object }
      before do
        expect(PasswordReset::SendForm).to receive(:new).with(email: 'email').and_return(form)
        expect(form).to receive(:submit).and_return(true)

        post :create, password_reset_send_form: { email: 'email' }
      end

      it 'should render "new" template with special flag' do
        expect(response).to redirect_to(home_page_url)
        expect(flash[:success]).not_to be_nil
      end
    end

    describe 'invalid credentials' do
      before do
        expect(PasswordReset::SendForm).to receive(:new).with(email: 'email').and_return(form)
        expect(form).to receive(:submit).and_return(false)

        post :create, password_reset_send_form: { email: 'email' }
      end

      it 'should render "new" template' do
        expect(response).to render_template(:new)
        expect(assigns(:send_form)).to eq form
      end
    end
  end


  describe 'GET #edit' do
    describe 'when user is found by token' do
      let(:user) { double('user') }
      before do
        expect(User).to receive(:find_by_reset_token).with('token').and_return(user)
      end

      it 'should render "edit" template' do
        get :edit, {token: 'token'}
        expect(response).to render_template(:edit)
      end

      it 'should pass form object into template' do
        form = double('reset_form')
        expect(PasswordReset::ResetForm).to receive(:new).and_return(form)
        get :edit, {token: 'token'}
        expect(assigns(:reset_form)).to eq form
      end
    end


    describe 'when user is not found by token' do
      before do
        expect(User).to receive(:find_by_reset_token).with('token').and_return(nil)
      end

      it 'should raise error 404' do
        expect { get :edit, {token: 'token'} }.to raise_error(ActionController::RoutingError)
      end
    end
  end


  describe 'PUT #update' do
    describe 'when user is not found by token' do
      before do
        expect(User).to receive(:find_by_reset_token).with('token').and_return(nil)
      end

      it 'should raise error 404' do
        expect { put :update, {token: 'token'} }.to raise_error(ActionController::RoutingError)
      end
    end

    describe 'when user is found by token and data is valid' do
      let(:user) { double('user') }
      let(:form) { double('reset_form') }
      before do
        expect(User).to receive(:find_by_reset_token).with('token').and_return(user)
        expect(PasswordReset::ResetForm).to receive(:new)
                                                .with(user, new_password: '1', new_password_confirmation: '1')
                                                .and_return(form)
        expect(form).to receive(:submit).and_return(true)
      end

      it 'should redirect to sign in page' do
        put :update, token: 'token', password_reset_reset_form: {new_password: '1', new_password_confirmation: '1'}
        expect(response).to redirect_to sign_in_url
      end
    end

    describe 'when user is found by token and data is not valid' do
      let(:user) { double('user') }
      let(:form) { double('reset_form') }
      before do
        expect(User).to receive(:find_by_reset_token).with('token').and_return(user)
        expect(PasswordReset::ResetForm).to receive(:new)
                                                .with(user, new_password: '1', new_password_confirmation: '1')
                                                .and_return(form)
        expect(form).to receive(:submit).and_return(false)
      end

      it 'should render edit template with form' do
        put :update, token: 'token', password_reset_reset_form: {new_password: '1', new_password_confirmation: '1'}
        expect(response).to render_template(:edit)
        expect(assigns(:reset_form)).to eq form
      end
    end
  end
end
