class CalendarController < ApplicationController
  before_filter :require_sign_in


  def index
    unless user_signed_in?
      redirect_to sign_in_url
    end

    if params[:year].nil? || params[:month].nil?
      current_date = date = Date.today
    else
      date = Date.new(params[:year].to_i, params[:month].to_i)
      current_date = Date.today
    end

    calendar_data_provider = DataProvider::UserCalendar.new(current_user)
    @month_grid_data = calendar_data_provider.month_grid_data(date, limit: 2, current_date: current_date)
  end


  def show
    @day = Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
  end
end