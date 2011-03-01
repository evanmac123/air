class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users

  def welcome_message
    self.custom_welcome_message || "You've joined the #{self.company_name} game! To play, send texts to this number. Send a text HELP if you want help."
  end

  def self.alphabetical
    order("company_name asc")
  end
end
