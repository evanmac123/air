class TileCompletion < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :tile

  validates_uniqueness_of :tile_id, :scope => [:user_id, :user_type]

  after_create :creator_has_tile_completed

  def creator_has_tile_completed
    creator = self.tile.creator
    if creator.nil? == false && 
       creator.has_own_tile_completed == false && 
       creator != self.user &&
       creator.creator_tile_completions.length == 1 # is the TileCompletion we just created the only one?
      
      creator.mark_own_tile_completed(self.tile)
    end
  end

  def self.for_tile(tile)
    where(:tile_id => tile.id)
  end

  def self.user_completed_any_tiles?(user_id, tile_ids)
    where(user_id: user_id, tile_id: tile_ids).count > 0
  end
  
  def has_user_joined?
    user_type == User.name && user.claimed?
  end
end
