require 'rails_helper'

describe CalendarController do
  describe 'GET #index' do
    it 'should render "index" view' do
      get :index
      expect(response).to render_template(:index)
    end

    it 'should pass to view formatted months' do
      formatter = double('formatter')
      month_list = double('month_list')

      expect(CalendarFormatter::Formatter).to receive(:new).and_return(formatter)
      expect(formatter).to receive(:month_list)
                               .with(Date.new(2015, 1), amount: 2)
                               .and_return(month_list)
      get :index, { year: 2015, month: 1 }

      expect(assigns(:month_list)).to eq month_list
    end
  end
end
