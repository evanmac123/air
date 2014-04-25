class UserTileLike < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile
  validates_uniqueness_of :tile_id, :scope => [:user_id]
end
