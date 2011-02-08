class Demo < ActiveRecord::Base
  has_many :users
  has_many :acts, :through => :users

  def self.alphabetical
    order("company_name asc")
  end
end
