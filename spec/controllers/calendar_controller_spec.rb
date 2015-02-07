require 'rails_helper'

describe CalendarController do

  describe 'GET #index' do

    describe 'when we are signed in' do

      before { controller_sign_in }

      it 'should render "index" view' do
        get :index
        expect(response).to render_template(:index)
      end

      it 'should pass to view received date' do
        get :index, { year: 2015, month: 1 }
        expect(assigns(:current_date)).to eq Date.new(2015, 1)
      end

      it 'should pass to view today date if date is not received' do
        today = Date.new(2001, 1)
        expect(Date).to receive(:today).and_return(today)

        get :index
        expect(assigns(:current_date)).to eq today
      end

      it 'should pass to view formatted months according to received date' do
        formatter = double('formatter')
        month_list = double('month_list')

        expect(CalendarFormatter::Formatter).to receive(:new).and_return(formatter)
        expect(formatter).to receive(:month_list)
                                 .with(Date.new(2015, 1), amount: 2)
                                 .and_return(month_list)
        get :index, { year: 2015, month: 1 }

        expect(assigns(:month_list)).to eq month_list
      end

      it 'should pass to view formatted month according to current date when date is not specified' do
        formatter = double('formatter')
        month_list = double('month_list')
        today = Date.new(2001, 1)

        expect(Date).to receive(:today).and_return(today)
        expect(CalendarFormatter::Formatter).to receive(:new).and_return(formatter)
        expect(formatter).to receive(:month_list)
                                 .with(today, amount: 2)
                                 .and_return(month_list)
        get :index

        expect(assigns(:month_list)).to eq month_list
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
