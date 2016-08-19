class DemoRequestsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    request = EmailInfoRequest.create(permitted_params)
    request.notify_the_ks_of_demo_request

    flash[:new_success] = "Thanks for requesting a demo!  Someone from our team will contact you within 24 hours."

    redirect_to root_path
  end

  def new
    @demo_request = EmailInfoRequest.new
  end

  protected

  def permitted_params
    params[:demo_request].permit!
  end
end
