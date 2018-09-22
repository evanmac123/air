# frozen_string_literal: true

class DemoRequestsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:marketing]
  layout "standalone"

  def create
    lead_contact = LeadContact.new(lead_contact_params)

    if user_valid(lead_contact) && lead_contact.save
      flash[:info] = "Thanks for requesting a demo! Someone from our team will reach out to you in the next 24 hours to schedule a time to chat."

      redirect_to about_path
    else
      LeadContactNotifier.duplicate_signup_request(lead_contact).deliver

      flash[:info] = "An Airbo account has already been requested with your email or phone number. Someone from our team will reach out to you shortly."

      redirect_to sign_in_path
    end
  end

  def marketing
    attrs = lead_contact_params
    marketing = attrs.delete(:marketing)
    if marketing
      lead_contact = LeadContact.new(attrs)
      if user_valid(lead_contact) && lead_contact.save
        render json: lead_contact
      else
        LeadContactNotifier.duplicate_signup_request(lead_contact).deliver
        render json: { duplicate: true }
      end
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
