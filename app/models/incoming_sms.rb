class IncomingSms < ActiveRecord::Base
  has_one :mate, :class_name => "OutgoingSms", :foreign_key => "mate_id"
end
