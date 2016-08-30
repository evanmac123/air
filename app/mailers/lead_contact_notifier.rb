class LeadContactNotifier < ActionMailer::Base
  default :from => "sales@airbo.com"
  helper :email
  has_delay_mail

  def signup_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Inbound Lead<sales@airbo.com>',
      :to      => 'team@airbo.com',
      :subject => "New Inbound Lead: Signup Request"
    )
  end

  def denial(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Airbo<sales@airbo.com>',
      :to      => @lead_contact.email,
      :subject => "Thanks for reaching out to Airbo!"
    )
  end

  def duplicate_signup_request(lead_contact)
    @lead_contact = lead_contact

    mail(
      :from    => 'Duplicate Signup Request<sales@airbo.com>',
      :to      => 'team@airbo.com',
      :subject => "Duplicate Signup Request"
    )
  end
end
