class Key < ActiveRecord::Base
  has_many :rules

  validates_presence_of   :name
  validates_uniqueness_of :name
end
