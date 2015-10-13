require 'rails_helper'

describe Profiles::NotificationsController do
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
          put :update, user: { notify_before: [0], notify_at: 0 }
          expect(response).to redirect_to(profile_notifications_url)
          expect(flash[:success]).not_to be_nil
        end

        it 'should update user with received arguments' do
          expect(@user).to receive(:update_attributes).with({ notify_before: [0], notify_at: 0 }).and_return true
          put :update, user: { notify_before: [0], notify_at: 0 }
        end
      end

      describe 'when data is not valid' do
        it 'should render "edit" template' do
          expect(@user).to receive(:update_attributes).and_return false
          put :update, user: { notify_before: [0], notify_at: 0 }
          expect(response).to render_template(:edit)
        end
      end
    end
  end
end