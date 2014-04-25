class UserTileCopy < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile
end
