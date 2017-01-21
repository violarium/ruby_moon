module Profiles
  class WebSubscriptionsController < ApplicationController
    before_filter :require_sign_in

    def create
      current_user.web_subscription = params[:subscription]
      current_user.save!
      head :ok
    end
  end
end