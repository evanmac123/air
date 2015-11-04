class DemoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    request = EmailInfoRequest.create!(params[:demo_request])
    request.notify_the_ks_of_demo_request
    head :ok
  end

  protected

  def modal_ping
    ping "Viewed HRM CTA Modal", {action: "Submitted Email Address"}, current_user
  end
end
