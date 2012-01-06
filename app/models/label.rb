class Label < ActiveRecord::Base
  belongs_to :rule
  belongs_to :tag
end
