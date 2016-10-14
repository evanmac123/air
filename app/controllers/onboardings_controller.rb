class OnboardingsController < ApplicationController
  skip_before_filter :authorize
  layout 'onboarding'

  def new
    @onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    if @onboarding_initializer.is_valid?
      @user_onboarding = @onboarding_initializer.user_onboarding
      if request.user_agent =~ /Mobile|webOS/
        ping('Mobile Onboarding', {email: params[:email], name: params[:name]})
        render template: "user_onboardings/onboarding_mobile"
      elsif @user_onboarding.new_record?
        sign_out
      else
        redirect_to user_onboarding_path(@user_onboarding)
      end
    else
      flash[:failure]="Your onboarding link appears to be invalid. Please click 'Contact Us' or 'Schedule a Demo' links below for assistance."
      redirect_to root_path
    end
  end

  def create
    on_it = OnboardingInitializer.new(onboarding_params)
    if on_it.save
      sign_in on_it.user
      render json: on_it.to_json, location: user_onboarding_path(on_it.user_onboarding), status: :ok
    else
      response.headers["X-Message"] = on_it.error
      head :unprocessable_entity
    end
  end


  private

    def onboarding_params
      {
        email:        params[:email],
        name:         params[:name],
        organization: params[:organization],
        board_id: params[:topic_board_id]
      }
    end
end
