class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo
end
