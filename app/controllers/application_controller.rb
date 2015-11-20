class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :set_locale

  include Authenticable

  private

  # Set locale according to params.
  # Also save selected locale to current user if it signed in.
  def set_locale
    locale = params[:locale]
    if locale.nil? || locale == ''
      I18n.locale = I18n.default_locale
    else
      I18n.locale = locale
    end
    self.default_url_options[:locale] = locale

    if current_user && current_user.locale != I18n.locale
      current_user.update(locale: I18n.locale)
    end
  end
end
