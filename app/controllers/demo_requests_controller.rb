class DemoRequestsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    request = EmailInfoRequest.create(permitted_params)
    request.notify_sales_of_demo_request

    flash[:new_success] = "Thanks for requesting a demo! We’ll email you within the next few hours to schedule a 30 minute overview."

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
