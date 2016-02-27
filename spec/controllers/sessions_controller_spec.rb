require 'rails_helper'

describe SessionsController do

  describe 'GET #new' do
    context 'not signed in user' do
      it 'should render new template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'should pass form object into template' do
        form = double('sign_in_form')
        expect(SignInForm).to receive(:new).and_return(form)
        get :new
        expect(assigns(:sign_in_form)).to eq form
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
    let(:form) { double('sign_in_form') }

    describe 'valid credentials' do
      let(:user) { double('user', id: '100').as_null_object }
      before do
        expect(SignInForm).to receive(:new).with(email: 'email', password: 'password').and_return(form)
        expect(form).to receive(:submit).and_return(user)

        post :create, sign_in_form: { email: 'email', password: 'password' }
      end

      it 'redirects to calendar page' do
        expect(response).to redirect_to(home_page_url)
      end
      it 'sets correct cookies' do
        expect(session[:user_id]).to eq '100'
      end
    end

    describe 'invalid credentials' do
      before do
        expect(SignInForm).to receive(:new).with(email: 'email', password: 'invalid').and_return(form)
        expect(form).to receive(:submit).and_return(nil)

        post :create, sign_in_form: { email: 'email', password: 'invalid' }
      end

      it 'should render "new" template' do
        expect(response).to render_template(:new)
      end
    end
  end


  describe 'DELETE #destroy' do

    it 'should redirect to home page' do
      delete :destroy
      expect(response).to redirect_to home_page_url
    end

    it 'should keep user session as nil' do
      session[:user_id] = 999
      delete :destroy
      expect(session[:user_id]).to be_nil
    end
  end
end
