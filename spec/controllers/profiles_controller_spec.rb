require 'rails_helper'

describe ProfilesController do
  describe 'GET #new' do
    context 'when user is not signed in' do
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

    context 'signed in user' do
      before { controller_sign_in }

      it 'should redirect to home page' do
        get :new
        expect(response).to redirect_to home_page_url
      end
    end
  end


  describe 'POST #create' do
    context 'when user is not signed in' do
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

      it 'should pass to view current user' do
        get :edit
        expect(assigns[:user]).to eq @user
      end
    end
  end

  describe 'PUT #update' do
    include_examples 'controller sign in required' do
      before { put :update }
    end

    describe 'when user signed in' do
      before { @user = controller_sign_in }

      describe 'when data is valid' do
        it 'should redirect to #edit with success flash message' do
          expect(@user).to receive(:update_attributes).and_return true
          put :update, user: { email: 'example@email.com' }
          expect(response).to redirect_to(profile_url)
          expect(flash[:success]).not_to be_nil
        end

        it 'should update user with received arguments' do
          expect(@user).to receive(:update_attributes).with(email: 'example@email.com',
                                                            time_zone: 'Sydney').and_return true
          put :update, user: { email: 'example@email.com', time_zone: 'Sydney' }
        end

        it 'should call rebuilding notifications' do
          notify_builder = double(NotificationBuilder)
          expect(NotificationBuilder).to receive(:new).and_return(notify_builder)
          expect(notify_builder).to receive(:rebuild_for).with(@user)
          put :update, user: { email: 'example@email.com', time_zone: 'Sydney' }
        end
      end

      describe 'when data is not valid' do
        it 'should render "edit" template' do
          expect(@user).to receive(:update_attributes).and_return false
          put :update, user: { email: 'example@email.com' }
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end