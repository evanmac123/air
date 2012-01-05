class Label < ActiveRecord::Base
  has_one :rule
  has_one :tag
end
