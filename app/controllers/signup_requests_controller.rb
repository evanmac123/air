class SignupRequestsController < ApplicationController
  skip_before_filter :authorize
  before_filter :allow_guest_user
  layout 'standalone', only: [:new]

  def create
    lead_contact = LeadContact.new(lead_contact_params)

    if user_valid(lead_contact) && lead_contact.save
      redirect_to root_path(signup_request: true)
    else
      LeadContactNotifier.duplicate_signup_request(lead_contact).deliver
      redirect_to root_path(failed_signup_request: true)
    end
  end

  def new
    @signup_request = LeadContact.new(email: params[:email])
  end

  protected

  def lead_contact_params
    params[:lead_contact].permit!
  end

  def user_valid(lead_contact)
    !User.exists?(email: lead_contact.email) && !User.exists?(phone_number: lead_contact.phone)
  end
end
