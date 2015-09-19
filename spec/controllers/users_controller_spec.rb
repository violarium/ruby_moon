require 'rails_helper'

describe UsersController do
  describe 'GET #new' do
    context 'not signed in user' do
      it 'should render "new" template' do
        get :new
        expect(response).to render_template(:new)
      end

      it 'should pass to view new user' do
        expect(User).to receive(:new).and_return('new user')
        get :new
        expect(assigns[:user]).to eq 'new user'
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
    context 'as not signed in user' do
      let(:user) { double(User, id: '100') }

      describe 'filter parameters' do
        it 'should pass to user exact parameters' do
          expect(User).to receive(:new).with(email: 'example@email.com',
                                             password: 'password',
                                             password_confirmation: 'password',
                                             time_zone: 'Moscow').and_return(user)
          allow(user).to receive(:valid?)
          allow(user).to receive(:save!)
          post :create, user: { email: 'example@email.com', password: 'password',
                                password_confirmation: 'password', time_zone: 'Moscow', hello: 'Hello' }
        end
      end

      describe 'valida data' do
        before do
          expect(User).to receive(:new).with(email: 'example@email.com',
                                             password: 'password',
                                             password_confirmation: 'password',
                                             time_zone: 'Moscow').and_return(user)
          expect(user).to receive(:valid?).and_return(true)
          expect(user).to receive(:save!)

          post :create, user: { email: 'example@email.com', password: 'password',
                                password_confirmation: 'password', time_zone: 'Moscow' }
        end

        it 'should call new user creation and redirect to home page with correct data' do
          expect(response).to redirect_to(home_page_url)
        end

        it 'sets correct cookies' do
          expect(session[:user_id]).to eq '100'
        end
      end

      describe 'invalid data' do
        before do
          expect(User).to receive(:new).with(email: 'example@email.com',
                                             password: '1',
                                             password_confirmation: '1').and_return(user)
          expect(user).to receive(:valid?).and_return(false)

          post :create, user: { email: 'example@email.com', password: '1',
                                password_confirmation: '1' }
        end

        it 'should render "new" template' do
          expect(response).to render_template(:new)
        end

        it 'should pass to view user variable' do
          expect(assigns[:user]).to eq (user)
        end
      end
    end
  end
end