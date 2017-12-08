class UnsubscribesController < ApplicationController
  def new
    @unsubscribe_service = UnsubscribeService.new(unsubscribe_params)
    render layout: 'external'
  end

  def create
    @service = UnsubscribeService.new(unsubscribe_params)

    if @service.valid_unsubscribe?
      if @service.user.end_user_in_all_boards?
        sign_in_and_move_into_board
      end

      ping('Unsubscribed', { email_type: @service.email_type }, @service.user)
      @service.unsubscribe

      flash[:success] = "You have been unsubscribed."
    else
      flash[:failure] = "You could not be unsubscribed at this time. Please try again."
    end

    redirect_to path_after_unsubscribe
  end

  private

    def unsubscribe_params
      params.permit(:user_id, :demo_id, :email_type, :token)
    end

    def path_after_unsubscribe
      if current_user.present?
        activity_path
      else
        sign_in_path
      end
    end

    def sign_in_and_move_into_board
      sign_in(@service.user, :remember_user)

      @service.user.move_to_new_demo(@service.demo_id) if @service.demo_id.present?
    end
end
