require 'digest/sha1'

class Player < ActiveRecord::Base
  belongs_to :demo

  before_create do
    self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
  end

  def self.alphabetical
    order("name asc")
  end

  def self.top
    order("points desc")
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

  def update_points(new_points)
    if new_points > 0
      increment!(:points, new_points)
    else
      decrement!(:points, new_points)
    end
  end
end
