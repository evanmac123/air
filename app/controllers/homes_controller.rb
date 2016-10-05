class HomesController < ApplicationController
  def show
    if request.cookies["user_onboarding"].present?
      redirect_to user_onboarding_path(current_user.user_onboarding.id) 
    else
      redirect_to activity_path, :format => :html
    end
  end
end
