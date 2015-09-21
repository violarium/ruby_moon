class UserSettingsController < ApplicationController
  before_filter :require_sign_in, only: [:edit_profile, :update_profile, :edit_password, :update_password]

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
    @password_form = PasswordForm.new(current_user)
  end

  def update_password
    @password_form = PasswordForm.new(current_user, password_params)
    if @password_form.submit
      flash[:success] = t('controllers.user_settings.password_updated')
      redirect_to edit_password_settings_url
    else
      render :edit_password
    end
  end


  private

  def profile_params
    params.require(:user).permit(:email, :time_zone)
  end

  def password_params
    params.require(:password_form).permit(:current_password, :new_password, :new_password_confirmation)
  end
end