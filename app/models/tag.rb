class Tag < ActiveRecord::Base
  validates :name, :uniqueness => true
  has_many :tags, :through => :labels
end
