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
    SMS.send(phone_number,
             "You've joined the #{demo.company_name} game!")
  end

  def gravatar_url(size)
    Gravatar.new(email).url(size)
  end
end
