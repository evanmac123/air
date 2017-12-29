class LeadContactNotifier < ApplicationMailer
  default :from => "team@airbo.com"
  helper :email

  def signup_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Inbound Lead<sales@airbo.com>',
      :to      => 'team@airbo.com',
      :subject => 'New Inbound Lead: Signup Request'
    )
  end

  def demo_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Inbound Lead<sales@airbo.com>',
      :to      => 'team@airbo.com',
      :subject => 'New Inbound Lead: Demo Request'
    )
  end

  def denial(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Airbo<team@airbo.com>',
      :to      => @lead_contact.email,
      :subject => 'Thanks for reaching out to Airbo!'
    )
  end

  def duplicate_signup_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Duplicate Signup Request<sales@airbo.com>',
      :to      => 'team@airbo.com',
      :subject => 'Duplicate Signup Request'
    )
  end
end
