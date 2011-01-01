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
end
