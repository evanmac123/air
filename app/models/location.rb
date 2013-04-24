class Location < ActiveRecord::Base
  belongs_to :demo
  has_many :users

  has_alphabetical_column :name

  validates_presence_of :name
end
