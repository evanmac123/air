class GamesController < ApplicationController
  skip_before_filter :authorize
  before_filter :display_social_links
  layout 'external' 

  def new
    if missing_information?
      remember_name_and_email
      show_error_next_request
      redirect_to :back
    end
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

  def remember_name_and_email
    flash[:customer_name] = params[:customer_name]
    flash[:customer_email] = params[:customer_email]
  end

  def show_error_next_request
    flash[:show_sign_up_form_error] = true
  end

  def missing_information?
    params[:customer_name].blank? || params[:customer_email].blank?
  end
end
