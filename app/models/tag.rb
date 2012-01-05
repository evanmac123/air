class Tag < ActiveRecord::Base
  validates :name, :uniqueness => true
  has_many :labels
  has_many :rules, :through => :labels
end
