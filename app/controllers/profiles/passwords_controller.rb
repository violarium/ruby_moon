module Profiles
  class PasswordsController < ApplicationController
    before_filter :require_sign_in

    def edit
      @password_form = PasswordForm.new(current_user)
    end

    def update
      @password_form = PasswordForm.new(current_user, password_params)
      if @password_form.submit
        flash[:success] = t('controllers.profiles.passwords.updated')
        redirect_to profile_password_url
      else
        render :edit
      end
    end

    private

    # Params to update password for current user.
    #
    # @return [Hash]
    def password_params
      params.require(:password_form).permit(:current_password, :new_password, :new_password_confirmation)
    end
  end
end