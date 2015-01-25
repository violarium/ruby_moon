class UserSessionsController < ApplicationController
  def new
    if user_signed_in?
      redirect_to home_page_url
    else
      @sign_in_form = SignInForm.new
    end
  end

  def create
    @sign_in_form = SignInForm.new
    user = @sign_in_form.submit(params[:sign_in_form])
    if user.nil?
      render :new
    else
      sign_in_user(user)
      redirect_to home_page_url
    end
  end

  def destroy
    sign_out
    redirect_to home_page_url
  end
end
