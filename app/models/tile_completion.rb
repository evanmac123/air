class TileCompletion < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :tile

  validates_uniqueness_of :tile_id, :scope => [:user_id, :user_type]

  after_create :creator_has_tile_completed

  def creator_has_tile_completed
    creator = self.tile.creator
    if creator.has_own_tile_completed == false && creator != self.user
      creator.mark_own_tile_completed
    end
  end

  def self.for_tile(tile)
    where(:tile_id => tile.id)
  end

  def self.already_displayed_one_final_time
    where(:displayed_one_final_time => true)
  end

  def self.mark_displayed_one_final_time(user)
    user.tile_completions.find_all do |completion|
      unless completion.displayed_one_final_time
        completion.displayed_one_final_time = true
        completion.save!
      end
    end
  end

  def self.waiting_to_display_one_final_time
    where(:displayed_one_final_time => false)
  end

  def self.without_mandatory_referrer
    # Assumes we've already joined to RuleTrigger
    where("trigger_rule_triggers.referrer_required" => false)
  end

  def self.user_completed_any_tiles?(user_id, tile_ids)
    where(user_id: user_id, tile_id: tile_ids).count > 0
  end
end
