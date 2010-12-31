class Player < ActiveRecord::Base
  belongs_to :demo

  def self.alphabetical
    order("name asc")
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end
end
