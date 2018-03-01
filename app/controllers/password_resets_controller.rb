class PasswordResetsController < ApplicationController
  def new
    if user_signed_in?
      redirect_to home_page_url
    else
      @send_form = PasswordReset::SendForm.new
    end
  end

  def create
    @send_form = PasswordReset::SendForm.new(params[:password_reset_send_form])
    if @send_form.submit
      flash[:success] = t('controllers.password_resets.sent')
      redirect_to home_page_url
    else
      render :new
    end
  end


  def edit
    user = User.find_by_reset_token(params[:token])
    if user
      @reset_form = PasswordReset::ResetForm.new(user)
    else
      raise ActionController::RoutingError.new('No user with such token')
    end
  end


  def update
    user = User.find_by_reset_token(params[:token])
    if user
      @reset_form = PasswordReset::ResetForm.new(user, params[:password_reset_reset_form])
      if @reset_form.submit
        flash[:success] = t('controllers.password_resets.updated')
        redirect_to sign_in_url
      else
        render :edit
      end
    else
      raise ActionController::RoutingError.new('No user with such token')
    end
  end
end