class CalendarController < ApplicationController
  PERIODS_TO_PREDICT = 3

  before_filter :require_sign_in

  def index
    unless user_signed_in?
      redirect_to sign_in_url
    end

    current_date = current_user.in_time_zone(Time.now).to_date
    if params[:year].nil? || params[:month].nil?
      date = current_date
    else
      date = Date.new(params[:year].to_i, params[:month].to_i)
    end

    @month_info = user_calendar_facade.month_info(date, current_date)
  end


  def edit
    @day_info = user_calendar_facade.day_info(received_day)
    @day_form = CalendarDayForm.new(current_user, received_day)
  end


  def update
    @day_form = CalendarDayForm.new(current_user, received_day, calendar_day_form_data)
     if @day_form.valid?
       @day_form.submit
       predictor.refresh_for(current_user, PERIODS_TO_PREDICT)
       redirect_to calendar_url(received_day.year, received_day.month)
     else
       render :edit
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

  # Get user calendar facade for current user.
  #
  def user_calendar_facade
    @user_calendar ||= UserCalendarFacade.new(current_user)
  end

  # Get received from params day.
  #
  # @return [Date]
  def received_day
    @date_from_params ||= Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end

  # Get predictor.
  #
  # @return [PeriodPredictor]
  def predictor
    @predictor ||= PeriodPredictor.new
  end
end