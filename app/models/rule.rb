class Rule < ActiveRecord::Base
  belongs_to :key

  validates_uniqueness_of :value, :scope => :key_id
end
