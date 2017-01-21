module Profiles
  class WebSubscriptionsController < ApplicationController
    before_filter :require_sign_in

    def create
      current_user.save_web_subscription(params[:subscription])
      head :ok
    end
  end
end