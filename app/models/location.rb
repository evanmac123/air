class Location < ActiveRecord::Base
  belongs_to :demo
  has_many :users

  def self.alphabetical
    order("name ASC")
  end
end
