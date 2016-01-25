require 'rails_helper'

describe CalendarController do

  describe 'GET #index' do

    include_examples 'controller sign in required' do
      before { get :index }
    end

    describe 'when we are signed in' do

      before do
        @user = controller_sign_in
      end

      before do
        expect(@user).to receive(:today_date).and_return(Date.new(2015, 1, 10))
      end

      it 'should render "index" view' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'should pass to view result of user calendar data provider' do
        user_calendar = double('user_calendar')
        expect(UserCalendarFacade).to receive(:new).with(@user).and_return(user_calendar)
        expect(user_calendar).to receive(:month_info)
                                     .with(Date.new(2015, 2), Date.new(2015, 1, 10)).and_return('month_info')

        get :index, { year: 2015, month: 2 }
        expect(assigns(:month_info)).to eq 'month_info'
      end

      it 'should get month info with today date if date is not received' do
        user_calendar = double('user_calendar')
        expect(UserCalendarFacade).to receive(:new).with(@user).and_return(user_calendar)
        expect(user_calendar).to receive(:month_info)
                                     .with(Date.new(2015, 1, 10), Date.new(2015, 1, 10)).and_return('month_info')

        get :index
        expect(assigns(:month_info)).to eq 'month_info'
      end
    end
  end


  describe 'GET #edit' do

    include_examples 'controller sign in required' do
      before { get :edit, { year: 2015, month: 1, day: 1 } }
    end


    describe 'when we are signed in' do
      let(:user) { FactoryGirl.create(:user) }
      before { controller_sign_in(user) }

      it 'should render "edit template"' do
        get :edit, { year: 2015, month: 1, day: 1 }
        expect(response).to render_template(:edit)
      end

      it 'should pass calendar day form to view' do
        form = double('calendar_form')
        expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1)).and_return(form)
        get :edit, { year: 2015, month: 1, day: 1 }
        expect(assigns[:day_form]).to eq(form)
      end

      it 'should pass day info to view' do
        data_provider = double('data_provider')
        expect(UserCalendarFacade).to receive(:new).with(user).and_return(data_provider)
        expect(data_provider).to receive(:day_info).with(Date.new(2015, 1, 1)).and_return('day info')

        get :edit, { year: 2015, month: 1, day: 1 }
        expect(assigns[:day_info]).to eq('day info')
      end
    end
  end


  describe 'PUT #update' do
    include_examples 'controller sign in required' do
      before { put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } } }
    end

    describe 'when we are signed in' do
      let(:user) { FactoryGirl.create(:user) }
      let(:day_form) { double('calendar_day_form') }

      before { controller_sign_in(user) }

      describe 'if form data is valid' do
        before do
          expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1), { params: 'foo' }).and_return(day_form)
          allow(day_form).to receive(:valid?).and_return true
          allow(day_form).to receive(:submit).and_return true
        end

        it 'should submit the form' do
          expect(day_form).to receive(:submit).and_return true
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end

        it 'should redirect to calendar url into month of current critical period' do
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(response).to redirect_to calendar_url(2015, 1)
        end

        it 'should call prediction of new periods' do
          predictor = double(PeriodPredictor)
          expect(PeriodPredictor).to receive(:default_predictor).and_return(predictor)
          expect(predictor).to receive(:refresh_for).with(user)
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end
      end


      describe 'if form data is not valid' do
        before do
          expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1), { params: 'foo' }).and_return(day_form)
          allow(day_form).to receive(:valid?).and_return(false)
        end

        it 'should not submit the form' do
          expect(day_form).not_to receive(:submit)
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end

        it 'should render "edit template"' do
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(response).to render_template(:edit)
        end

        it 'should pass to template form' do
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
          expect(assigns[:day_form]).to eq(day_form)
        end

        it 'should not call prediction of new periods' do
          expect(PeriodPredictor).not_to receive(:default_predictor)
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end

        it 'should not call rebuilding notifications' do
          expect(NotificationBuilder).not_to receive(:new)
          put :update, { year: 2015, month: 1, day: 1, calendar_day_form: { params: 'foo' } }
        end
      end


      describe 'where there are no form data' do
        before do
          allow(day_form).to receive(:valid?).and_return true
          allow(day_form).to receive(:submit).and_return true
        end

        it 'should receive empty data to form' do
          expect(day_form).to receive(:submit).and_return true
          expect(CalendarDayForm).to receive(:new).with(user, Date.new(2015, 1, 1), { }).and_return(day_form)
          put :update, { year: 2015, month: 1, day: 1 }
        end

        it 'should call prediction of new periods' do
          predictor = double(PeriodPredictor)
          expect(PeriodPredictor).to receive(:default_predictor).and_return(predictor)
          expect(predictor).to receive(:refresh_for).with(user)
          put :update, { year: 2015, month: 1, day: 1}
        end
      end
    end
  end
end
