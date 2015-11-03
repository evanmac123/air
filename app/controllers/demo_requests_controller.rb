class DemoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    DemoRequest.create(params[:demo_request])
    head :ok
  end

end

