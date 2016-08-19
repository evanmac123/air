class SignupRequestsController < ApplicationController
  layout 'external'
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    request = EmailInfoRequest.create(permitted_params)
    request.notify_sales_of_signup_request

    flash[:new_success] = "Thanks for signing up with Airbo!  Someone from our team will contact you within 24 hours to get you setup!"

    redirect_to root_path
  end

  def new
    @signup_request = EmailInfoRequest.new(email: params[:email])
  end

  protected

  def permitted_params
    params[:request].permit!
  end
end
