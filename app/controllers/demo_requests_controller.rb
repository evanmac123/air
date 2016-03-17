class DemoRequestsController < ApplicationController
  skip_before_filter :authorize

  def create
    request = EmailInfoRequest.create!(permitted_params)
    request.notify_the_ks_of_demo_request
    # ping
    render json: {email: permitted_params[:email]}
  end

  protected

  def permitted_params
    params[:demo_request].permit!
  end

  # def ping
  #   ping "New Lead", {action: "Submitted Email - v. 3.17.16", page_name: ""}, current_user
  # end
end
