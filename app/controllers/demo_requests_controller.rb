class DemoRequestsController < ApplicationController
  skip_before_filter :authenticate

  layout 'standalone'

  def create
    request = EmailInfoRequest.create(permitted_params)
    request.notify
    redirect_to root_path(demo_request: true)
  end

  def new
    @demo_request = EmailInfoRequest.new
  end

  protected

  def permitted_params
    params[:request].permit!
  end
end
