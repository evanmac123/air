class OnboardingsController < ApplicationController
  skip_before_filter :authorize
  layout 'onboarding'

  def new
    if valid_params
      find_org_onboarding
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
    else
      redirect_to new_signup_request_path
    end
  end

  def create
    on_it = OnboardingInitializer.new(onboarding_params)
    if on_it.save
      sign_in on_it.user
      ping("Onboarding", { kpi: "selects priority", user_onboarding_id: on_it.user_onboarding.id, user_onboarding_state: on_it.user_onboarding.state })

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

    def valid_params
      params[:email] && params[:name] && params[:organization]
    end

    def find_org_onboarding
      organization = Organization.joins(onboarding: :user_onboardings).where(name: params[:organization]).first
      @onboarding = organization.onboarding
    end
end
