# frozen_string_literal: true

class LeadContactNotifier < ApplicationMailer
  default from: "team@airbo.com"
  helper :email

  def notify_sales(lead_contact)
    @lead_contact = lead_contact

    mail(
      from: "Inbound Lead<sales@airbo.com>",
      to: "team@airbo.com",
      subject: lead_contact.source
    )
  end

  def duplicate_signup_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      from: "Duplicate Signup Request<sales@airbo.com>",
      to: "team@airbo.com",
      subject: "Duplicate Signup Request"
    )
  end
end
