class ProfilesController < ApplicationController
  before_filter :require_sign_in, except: [:new, :create]

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

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(update_profile_params)
      NotificationBuilder.new.rebuild_for(current_user)
      flash[:success] = t('controllers.profiles.updated')
      redirect_to profile_url
    else
      render :edit
    end
  end


  private

  # Params for sign up.
  #
  # @return [Hash]
  def sign_up_params
    params.require(:user).permit(:email, :password, :password_confirmation, :time_zone)
  end

  # Params to update profile
  #
  # @return [Hash]
  def update_profile_params
    params.require(:user).permit(:email, :time_zone)
  end
end