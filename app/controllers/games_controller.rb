class GamesController < ApplicationController
  skip_before_filter :authorize
  layout 'external' 

  def new
    redirect_if_missing_information
  end

  def create
    notify_the_ks_of_game_request
    redirect_to page_path("waitingroom")
  end

  private

  def notify_the_ks_of_game_request
    game_creation_request = GameCreationRequest.create(
      customer_name:  params[:customer_name], 
      customer_email: params[:customer_email], 
      company_name:   params[:company_name],
      interests:      params[:interests]
    )

    game_creation_request.schedule_notification
  end

  def redirect_if_missing_information
    unless params[:customer_name].present? && params[:customer_email].present?
      redirect_to :back
    end
  end
end
