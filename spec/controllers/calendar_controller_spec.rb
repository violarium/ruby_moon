require 'rails_helper'

describe CalendarController do

  describe 'GET #index' do

    describe 'when we are signed in' do

      before do
        @user = controller_sign_in
      end

      it 'should render "index" view' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'should pass to view result of user calendar data provider' do
        user_calendar = double('user_calendar')
        expect(DataProvider::UserCalendar).to receive(:new).with(@user).and_return(user_calendar)
        expect(Date).to receive(:today).and_return(Date.new(2015, 1, 10))
        expect(user_calendar).to receive(:month_grid_data)
                                     .with(Date.new(2015, 1), limit: 2, current_date: Date.new(2015, 1, 10))
                                     .and_return('month_grid_data')

        get :index, { year: 2015, month: 1 }
        expect(assigns(:month_grid_data)).to eq 'month_grid_data'
      end

      it 'should call calendar data provider with today date if date is not received' do
        user_calendar = double('user_calendar')
        expect(DataProvider::UserCalendar).to receive(:new).with(@user).and_return(user_calendar)
        expect(Date).to receive(:today).and_return(Date.new(2015, 1, 10))
        expect(user_calendar).to receive(:month_grid_data)
                                     .with(Date.new(2015, 1, 10), limit: 2, current_date: Date.new(2015, 1, 10))
                                     .and_return('month_grid_data')

        get :index
        expect(assigns(:month_grid_data)).to eq 'month_grid_data'
      end
    end


    describe 'when we are not signed in' do
      it 'should redirect to sign in action with error flash' do
        get :index
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end
  end
end
