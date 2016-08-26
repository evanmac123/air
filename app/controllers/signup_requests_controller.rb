class SignupRequestsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    LeadContact.create(lead_contact_params)

    redirect_to root_path(signup_request: true)
  end

  def new
    @signup_request = LeadContact.new(email: params[:email])
  end

  protected

  def lead_contact_params
    params[:lead_contact].permit!
  end
end
