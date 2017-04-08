module Profiles
  class WebSubscriptionsController < ApplicationController
    before_filter :require_sign_in

    def create
      UserWebSubscription.save_subscription(current_user, params[:subscription])
      UserWebSubscription.clean_up_for_user(current_user)
      head :ok
    end
  end
end