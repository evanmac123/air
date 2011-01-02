require 'digest/sha1'

class Player < ActiveRecord::Base
  belongs_to :demo

  before_create do
    self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
  end

  def self.alphabetical
    order("name asc")
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def join_game(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
    send_welcome_sms
  end

  def send_welcome_sms
    Twilio::SMS.create(:to   => phone_number,
                       :from => TWILIO_PHONE_NUMBER,
                       :body => "You've joined the #{demo.company_name} game!")
  end
end
