class ProfilesController < ApplicationController
  before_filter :require_sign_in

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_attributes(profile_params)
      flash[:success] = t('controllers.profiles.updated')
      redirect_to profile_url
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:user).permit(:email, :time_zone)
  end
end