class Player < ActiveRecord::Base
  belongs_to :demo

  def self.alphabetical
    order("name asc")
  end
end
