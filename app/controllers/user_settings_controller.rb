class UserSettingsController < ApplicationController
  before_filter :require_sign_in, only: [:edit_profile, :update_profile]

  def edit_profile
    @user = current_user
  end

  def update_profile
    @user = current_user
    if @user.update_attributes(profile_params)
      flash[:success] = t('controllers.user_settings.profile_updated')
      redirect_to edit_profile_settings_url
    else
      render :edit_profile
    end
  end

  def edit_password

  end

  def edit_notifications

  end

  def show_delete

  end


  private

  def profile_params
    params.require(:user).permit(:email, :time_zone)
  end
end