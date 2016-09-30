class OnboardingsController < ApplicationController
  skip_before_filter :authorize
  layout 'onboarding'

  def new
    if should_onboard?
      sign_out
      @topic_boards = TopicBoard.reference_board_set
      @onboarding_initializer = OnboardingInitializer.new(onboarding_params)
      @user_onboarding = UserOnboarding.new(state: 1)
    else
      redirect_to "/myairbo/#{@user.user_onboarding.id}"
    end
  end

  def create
    onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    if should_onboard? 
      onboarding_initializer.save
      if onboarding_initializer.error.nil?
        cookie[:user_onboarding]=  onboarding_initializer.user_onboarding.auth_hash
        redirect_to "/myairbo/#{onboarding_initializer.user_onboarding_id}" and return
      else
        flash[:errors]=onboarding_initializer.error.message
      end
    end

    redirect_to root_path
  end


  private

    def should_onboard?
      @user = User.where(email: params[:email]).first_or_initialize
      @user.user_onboarding.nil?
    end

    def onboarding_params
      {
        email:        params[:email],
        name:         params[:name],
        organization: params[:organization],
        board_id: params[:topic_board_id]
      }
    end
end
