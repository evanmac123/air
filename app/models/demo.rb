class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users

  def welcome_message(user)
    self.custom_welcome_message || "You've joined the #{self.company_name} game! Your unique ID is #{user.sms_slug} (text MYID for a reminder). To play, send texts to this #. Send a text HELP for help."
  end

  def self.alphabetical
    order("company_name asc")
  end
end
