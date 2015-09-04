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
    @upcoming_period = current_user.upcoming_critical_period(@current_date)
  end


  def show
    @day_info = @calendar_data_provider.day_info(received_date)
    @day_form = CalendarDayForm.new(current_user, received_date)
  end


  def update
    @day_form = CalendarDayForm.new(current_user, received_date, calendar_day_form_data)
     if @day_form.valid?
       @day_form.submit
       redirect_to calendar_url(received_date.year, received_date.month)
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

  # Get data for calendar day form.
  #
  # @return [Hash]
  def calendar_day_form_data
    form_data = params[:calendar_day_form]
    form_data = { } if form_data.nil?
    form_data
  end

  # Get received from params date.
  #
  # @return [Date]
  def received_date
    @date_from_params ||= Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
end