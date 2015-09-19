class UsersController < ApplicationController
  def new
    redirect_to home_page_url if user_signed_in?
    @user = User.new
  end

  def create
    @user = User.new(sign_up_params)
    if @user.valid?
      @user.save!
      sign_in_user(@user)
      redirect_to home_page_url
    else
      render :new
    end
  end

  private

  # Params for sign up.
  #
  # @return [Hash]
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :time_zone)
  end
end