class OutgoingSms < ActiveRecord::Base
  belongs_to :mate, :class_name => "IncomingSms"
end
