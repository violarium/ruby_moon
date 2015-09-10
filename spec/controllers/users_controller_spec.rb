require 'rails_helper'

describe UsersController do
  describe 'GET #new' do
    context 'not signed in user' do
      it 'should render new template' do
        get :new
        expect(response).to render_template(:new)
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
end