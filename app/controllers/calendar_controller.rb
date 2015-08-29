class CalendarController < ApplicationController
  before_filter :require_sign_in
  before_filter :set_up_data_provider


  def index
    unless user_signed_in?
      redirect_to sign_in_url
    end

    @current_date = Date.today
    if params[:year].nil? || params[:month].nil?
      date = @current_date
    else
      date = Date.new(params[:year].to_i, params[:month].to_i)
    end

    @month_grid_data = @calendar_data_provider.month_grid_data(date)
    @upcoming_period = current_user.upcoming_critical_period(date)
  end


  def show
    @day_info = @calendar_data_provider.day_info(params)
    @day_form = CalendarDayForm.new(current_user, @day_info[:date])
  end


  def update
    @day_info = @calendar_data_provider.day_info(params)
    @day_form = CalendarDayForm.new(current_user, @day_info[:date], params[:calendar_day_form])
     if @day_form.valid?
       @day_form.submit
       redirect_to calendar_url(@day_info[:date].year, @day_info[:date].month)
     else
       render :show
     end
  end


  private


  # Set up calendar data provider for current user
  #
  def set_up_data_provider
    @calendar_data_provider = DataProvider::UserCalendar.new(current_user)
  end
end