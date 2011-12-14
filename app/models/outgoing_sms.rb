class OutgoingSms < ActiveRecord::Base
  belongs_to :in_response_to, :class_name => "IncomingSms"
end
