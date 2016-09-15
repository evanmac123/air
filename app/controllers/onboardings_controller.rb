class OnboardingsController < ApplicationController
  skip_before_filter :authorize
  layout 'onboarding'

  def new
    if should_onboard?
      @topic_boards = TopicBoard.reference_board_set
      @onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    else
      redirect_to "/myairbo/#{@user.user_onboarding.id}"
    end
  end

  def create
    onboarding_initializer = OnboardingInitializer.new(onboarding_params)
    binding.pry
    if should_onboard? && onboarding_initializer.save
      redirect_to "/myairbo/#{onboarding_initializer.user_onboarding_id}"
    else
      redirect_to root_path
    end
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
