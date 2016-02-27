module Authenticable
  extend ActiveSupport::Concern

  private


  # Sign in user.
  #
  # @param user [User]
  # @param remember [Boolean]
  def sign_in_user(user, remember = false)
    clear_current_user
    set_current_user { user }

    session[:user_id] = user.id.to_s
    cookies.permanent.signed[:user_token] = user.create_token if remember
  end


  # Sign out user.
  def sign_out
    clear_current_user

    session[:user_id] = nil
    user_token = find_user_token
    user_token.delete unless user_token.nil?
    cookies.delete(:user_token)
  end


  # Get current signed in user.
  #
  # @return [User] return current user or nil
  def current_user
    set_current_user do
      user = User.where(id: session[:user_id]).first
      if user.nil?
        user_token = find_user_token
        unless user_token.nil?
          user_token.prolong
          user_token.save
          user = user_token.user
        end
      end

      user
    end
  end


  # Find user token by cookie which is not expired.
  #
  # @return [UserToken]
  def find_user_token
    token_string = cookies.signed[:user_token]
    if token_string.nil?
      nil
    else
      UserToken.with_token(token_string).not_expired.first
    end
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