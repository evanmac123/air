class DemoRequestsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user

  def create
    request = EmailInfoRequest.create!(permitted_params)
    request.notify_the_ks_of_demo_request
    render json: {email: permitted_params[:email]}
  end

  def new
    @request = EmailInfoRequest.new
  end

  protected

  def permitted_params
    params[:demo_request].permit!
  end
end
