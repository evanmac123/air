class TileCompletion < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile

  after_update do
    check_for_new_available_tiles if changed.include?('satisfied')
  end

  
  def self.for_tile(tile)
    where(:tile_id => tile.id)
  end

  def self.satisfied
    where(:satisfied => true)
  end

  def self.unsatisfied
    where(:satisfied => false)
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
    satisfied.where(:displayed_one_final_time => false)
  end

  # def self.displayable
    # where("satisfied = false OR (satisfied = true AND display_completion_on_next_request = true)").where(:tile_id => Tile.due_ids)
  # end

  def self.without_mandatory_referrer
    # Assumes we've already joined to RuleTrigger
    where("trigger_rule_triggers.referrer_required" => false)
  end

  def satisfaction_message
    points = self.tile.bonus_points

    if points && points > 0
      bonus_phrase = if points == 1
                       "1 bonus point"
                     else
                       "#{points} bonus points"
                     end

      "Congratulations! You've earned #{bonus_phrase} for completing a daily dose."
    else
      "Congratulations! You've completed a daily dose."
    end
  end

  protected

  def check_for_new_available_tiles
    potentially_available_tiles = Prerequisite.where(:prerequisite_tile_id => self.tile.id).map(&:tile).uniq

    potentially_available_tiles.each do |potentially_available_tile|
      if self.user.satisfies_all_prerequisites(potentially_available_tile) && potentially_available_tile.due?
        potentially_available_tile.suggest_to_user(self.user)
      end
    end
  end
end
