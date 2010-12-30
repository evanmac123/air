class Demo < ActiveRecord::Base
  has_many :players

  def self.alphabetical
    order("company_name asc")
  end
end
