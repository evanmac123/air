# frozen_string_literal: true

class SignupRequestsController < ApplicationController
  layout "standalone"

  def create
    lead_contact = LeadContact.new(lead_contact_params)

    if user_valid(lead_contact) && lead_contact.save
      flash[:info] = "Thanks for signing up! Someone from our team will reach out to you in the next 24 hours to get you set up."

      redirect_to root_path
    else
      LeadContactNotifier.duplicate_signup_request(lead_contact).deliver

      flash[:info] = "An Airbo account has already been requested with your email or phone number. Someone from our team will reach out to you shortly."
      redirect_to root_path
    end
  end

  def new
    @marketing_site_request = LeadContact.new
  end

  private

    def lead_contact_params
      params[:lead_contact].permit!
    end

    def user_valid(lead_contact)
      !User.exists?(email: lead_contact.email) && !User.exists?(phone_number: lead_contact.phone)
    end
end
