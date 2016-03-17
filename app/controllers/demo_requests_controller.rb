class DemoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    request = EmailInfoRequest.create!(permitted_params)
    request.notify_the_ks_of_demo_request
    modal_ping
    render json: {email: permitted_params[:email]}
  end

  protected

  def permitted_params
    params[:demo_request].permit!
  end

  def modal_ping
    ping "Viewed HRM CTA Modal", {action: "Submitted Email Address"}, current_user
  end
end
