class Location < ActiveRecord::Base
  belongs_to :demo
  has_many :users

  has_alphabetical_column :name

  validates_presence_of :name

  def self.name_ilike(search_term)
    where("name ILIKE ?", "%#{search_term}%")
  end
end
