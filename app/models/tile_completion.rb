class TileCompletion < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :tile, counter_cache: true

  scope :for_period, ->(b,e){where(:created_at => b..e)}

  validates_uniqueness_of :tile_id, :scope => [:user_id, :user_type]

  after_create :creator_has_tile_completed

  def creator_has_tile_completed
    # OPTZ: this can run asynchronously

    creator = self.tile.creator
    if creator.nil? == false &&
       creator.has_own_tile_completed == false &&
       creator != self.user &&
       creator.creator_tile_completions.limit(2).length == 1
       # is the TileCompletion we just created the only one?
       # The "limit 2" there is a DB optimization: we were getting long-running
       # queries due to counting up ALL tile completions for this creator when
       # all we really want to know is, is there more than one. Throwing in the
       # limit turned a typical query from 500 ms to 0.1 ms, or a 5000X
       # speedup. Not bad for less than ten extra characters.

      creator.mark_own_tile_completed(self.tile)
    end
  end

  def self.user_completed_any_tiles?(user_id, tile_ids)
    where(user_id: user_id, tile_id: tile_ids).count > 0
  end
end
