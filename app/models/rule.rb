class Rule < ActiveRecord::Base
  belongs_to :key

  validates_presence_of   :key_id, :value
  validates_uniqueness_of :value, :scope => :key_id
end
