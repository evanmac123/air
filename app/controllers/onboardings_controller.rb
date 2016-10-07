class OnboardingsController < ApplicationController
  skip_before_filter :authorize
  layout 'onboarding'

  def new

    @onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    if @onboarding_initializer.has_no_active_user_onboarding?
      sign_out
    else
      redirect_to "/myairbo/#{@onboarding_initializer.user_onboarding_id}"
    end
  end

  def create
    on_it = OnboardingInitializer.new(onboarding_params)

    if on_it.save
      uob = on_it.user_onboarding
      render json:{ uob: on_it.user_onboarding_id, hash: uob.auth_hash }, location: user_onboarding_path(uob), status: :ok
    else
      head :unprocessable_entity, response.headers["X-Message"]=on_it.error
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
