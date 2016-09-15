class OnboardingsController < ApplicationController
  skip_before_filter :authorize, only: [:create]
  layout 'onboarding'

  def create
    onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    if should_onboard? && onboarding_initializer.save
      redirect_to "/myairbo/#{onboarding_initializer.user_onboarding_id}"
    else
      redirect_to root_path
    end
  end

  private
    def should_onboard?
      params[:onboard]
      #  && !current_user
    end

    def onboarding_params
      {
        email:        params[:email],
        name:         params[:name],
        organization: params[:organization]
      }
    end
end
