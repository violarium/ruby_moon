require 'rails_helper'

describe ProfilesController do
  describe 'GET #edit' do
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        get :edit
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
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
    describe 'when user not signed in' do
      it 'should redirect to sign in action with error flash' do
        put :update
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
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
          expect(response).to redirect_to(profile_url)
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