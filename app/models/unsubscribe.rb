class Unsubscribe < ActiveRecord::Base
  belongs_to :user

  def self.url(user)
    base = "https://sendgrid.com/api/unsubscribes.add.xml?api_user=[api_email]&api_key=[api_key]&email=[email_to_unsubscribe]"
    base.sub!('[api_email]', sendgrid_username)
    base.sub!('[api_key]', sendgrid_password)
    base.sub('[email_to_unsubscribe]', user.email)
  end

  protected

  def self.sendgrid_username
    if Rails.env.test?
      SendGrid::DEV_USERNAME
    else
      ActionMailer::Base.smtp_settings[:user_name]
    end
  end

  def self.sendgrid_password
    if Rails.env.test?
      SendGrid::DEV_PASSWORD
    else
      ActionMailer::Base.smtp_settings[:password]
    end
  end


end
