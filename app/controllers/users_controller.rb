class UsersController < ApplicationController
  def new
    redirect_to home_page_url if user_signed_in?
  end

  def create

  end

  def edit

  end

  def update

  end
end