class DemoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    request = EmailInfoRequest.create!(params[:demo_request])
    request.notify_the_ks_of_demo_request
    head :ok
  end

end

