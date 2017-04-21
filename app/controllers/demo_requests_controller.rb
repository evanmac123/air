class DemoRequestsController < ApplicationController
  layout 'standalone'

  def create
    request = EmailInfoRequest.create(permitted_params)
    request.notify

    flash[:success] = "Thanks for requesting a demo! Someone from our team will reach out to you in the next 24 hours to schedule a time to chat."
    redirect_to root_path
  end

  def new
    @demo_request = EmailInfoRequest.new
  end

  protected

  def permitted_params
    params[:request].permit!
  end
end
