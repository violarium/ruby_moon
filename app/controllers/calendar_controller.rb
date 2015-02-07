class CalendarController < ApplicationController
  before_filter :require_sign_in

  def index
    unless user_signed_in?
      redirect_to sign_in_url
    end

    if params[:year].nil? || params[:month].nil?
      date = Date.today
    else
      date = Date.new(params[:year].to_i, params[:month].to_i)
    end

    formatter = CalendarFormatter::Formatter.new
    @current_date = date
    @month_list = formatter.month_list(date, amount: 2)
    @prev_month = date - 1.month
    @next_month = date + 1.month
  end
end