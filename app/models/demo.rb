class Demo < ActiveRecord::Base
  def self.alphabetical
    order("company_name asc")
  end
end
