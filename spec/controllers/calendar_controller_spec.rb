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
        expect(user_calendar).to receive(:month_grid_data).with(Date.new(2015, 1)).and_return('month_grid_data')

        get :index, { year: 2015, month: 1 }
        expect(assigns(:month_grid_data)).to eq 'month_grid_data'
      end

      it 'should call calendar data provider with today date if date is not received' do
        user_calendar = double('user_calendar')
        expect(DataProvider::UserCalendar).to receive(:new).with(@user).and_return(user_calendar)
        expect(Date).to receive(:today).and_return(Date.new(2015, 1, 10))
        expect(user_calendar).to receive(:month_grid_data).with(Date.new(2015, 1, 10)).and_return('month_grid_data')

        get :index
        expect(assigns(:month_grid_data)).to eq 'month_grid_data'
      end

      it 'should pass to view current date' do
        expect(Date).to receive(:today).and_return(Date.new(2015, 1, 10))
        get :index
        expect(assigns(:current_date)).to eq Date.new(2015, 1, 10)
      end

      it 'should pass info about upcoming critical period' do
        expect(Date).to receive(:today).and_return(Date.new(2015, 1, 10))

        expect(@user).to receive(:upcoming_critical_period).with(Date.new(2015, 1, 10)).and_return('upcoming_period')
        get :index
        expect(assigns(:upcoming_period)).to eq 'upcoming_period'
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


  describe 'GET #show' do
    describe 'when we are not signed in' do
      it 'should redirect to sign in action with error flash' do
        get :show, { year: 2015, month: 1, day: 1 }
        expect(response).to redirect_to(sign_in_url)
        expect(flash[:error]).not_to be_nil
      end
    end


    describe 'when we are signed in' do
      let(:user) { FactoryGirl.create(:user) }
      before { controller_sign_in(user) }

      it 'should render "show template"' do
        get :show, { year: 2015, month: 1, day: 1 }
        expect(response).to render_template(:show)
      end

      it 'should pass calendar day form to view' do
        form = double('calendar_form')
        expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1)).and_return(form)
        get :show, { year: 2015, month: 1, day: 1 }
        expect(assigns[:day_form]).to eq(form)
      end
    end
  end


  describe 'PUT #update' do
    describe 'when we are signed in' do
      let(:user) { FactoryGirl.create(:user) }
      before { controller_sign_in(user) }

      let(:day_form) { double('calendar_day_form') }
      before do
        expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1), { params: 'foo' }).and_return(day_form)
      end

      describe 'if form data is valid' do
        before { allow(day_form).to receive(:valid?).and_return(true) }

        it 'should submit the form' do
          expect(day_form).to receive(:submit).and_return true
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end

        it 'should redirect to calendar url into month of current critical period' do
          allow(day_form).to receive(:submit).and_return true
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(response).to redirect_to calendar_url(2015, 1)
        end
      end

      describe 'if form data is not valid' do
        before { allow(day_form).to receive(:valid?).and_return(false) }

        it 'should not submit the form' do
          expect(day_form).not_to receive(:submit)
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end

        it 'should render "show template"' do
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(response).to render_template(:show)
        end

        it 'should pass to template form' do
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(assigns[:day_form]).to eq(day_form)
        end
      end
    end
  end
end
