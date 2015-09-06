class CalendarController < ApplicationController
  before_filter :require_sign_in

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

    @month_grid_data = user_calendar.month_grid_data(date)
    @upcoming_period = current_user.upcoming_critical_period(@current_date)
  end


  def show
    @day_info = user_calendar.day_info(received_date)
    @day_form = CalendarDayForm.new(current_user, received_date)
  end


  def update
    @day_form = CalendarDayForm.new(current_user, received_date, calendar_day_form_data)
     if @day_form.valid?
       @day_form.submit
       predictor.refresh_for(current_user, 3)
       redirect_to calendar_url(received_date.year, received_date.month)
     else
       render :show
     end
  end


  private

  # Get data for calendar day form.
  #
  # @return [Hash]
  def calendar_day_form_data
    form_data = params[:calendar_day_form]
    form_data = { } if form_data.nil?
    form_data
  end

  # Get user calendar model for current user.
  #
  def user_calendar
    @user_calendar ||= UserCalendar.new(current_user)
  end

  # Get received from params date.
  #
  # @return [Date]
  def received_date
    @date_from_params ||= Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end

  def predictor
    @predictor ||= PeriodPredictor.new
  end
end