module Profiles
  class NotificationsController < ApplicationController
    before_filter :require_sign_in

    def edit
      @user = current_user
    end

    def update
      @user = current_user
      if @user.update_attributes(notifications_params)
        flash[:success] = t('controllers.profiles.notifications.updated')
        redirect_to profile_notifications_url
      else
        render :edit
      end
    end

    private

    # Params to update notifications.
    #
    # @return [Hash]
    def notifications_params
      notify_before = params.require(:user)[:notify_before].map { |i| i.to_i }
      notify_at = params.require(:user)[:notify_at].to_i
      { notify_before: notify_before, notify_at: notify_at }
    end
  end
end