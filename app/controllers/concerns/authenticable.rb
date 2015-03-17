module Authenticable
  extend ActiveSupport::Concern

  private


  # Sign in user.
  #
  # @param user [User]
  def sign_in_user(user)
    clear_current_user
    set_current_user { user }
    session[:user_id] = user.id.to_s
  end


  # Sign out user.
  def sign_out
    clear_current_user
    session[:user_id] = nil
  end


  # Get current signed in user.
  #
  # @return [User] return current user or nil
  def current_user
    set_current_user { User.where(id: session[:user_id]).first }
  end


  # Set user as current if it's not already set.
  #
  # @yield block which will return user
  #
  # @return [User]
  def set_current_user(&block)
    unless @current_user_initialized
      @current_user = block.call
      @current_user_initialized = true
    end
    @current_user
  end


  # Clear current user.
  def clear_current_user
    @current_user = nil
    @current_user_initialized = false
  end


  # Check if user is signed in.
  #
  # @return [Boolean]
  def user_signed_in?
    !current_user.nil?
  end


  # Filter to require sign in
  def require_sign_in
    unless user_signed_in?
      flash[:error] = t('controllers.concerns.authenticable.require_sign_in')
      redirect_to sign_in_url
    end
  end


  included do
    helper_method :current_user, :user_signed_in?
  end
end