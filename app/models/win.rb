class Win < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo

  validates_presence_of :user_id, :demo_id
end
