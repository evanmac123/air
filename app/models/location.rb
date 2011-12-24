class Location < ActiveRecord::Base
  belongs_to :demo
  has_many :users

  has_alphabetical_column :name
end
