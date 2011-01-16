class Demo < ActiveRecord::Base
  has_many :users

  def self.alphabetical
    order("company_name asc")
  end
end
