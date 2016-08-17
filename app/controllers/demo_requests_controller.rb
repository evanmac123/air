class DemoRequestsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    request = EmailInfoRequest.create!(permitted_params)
    request.notify_the_ks_of_demo_request
    render json: {email: permitted_params[:email]}
  end

  def new
    @user = User.new(email: params[:email])
    @board = Demo.new
  end

  protected

  def permitted_params
    params[:demo_request].permit!
  end
end
