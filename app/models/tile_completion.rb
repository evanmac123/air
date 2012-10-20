class TileCompletion < ActiveRecord::Base
  belongs_to :user
  belongs_to :tile
  validates_uniqueness_of :tile_id, :scope => :user_id

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

  def satisfaction_message
    points = self.tile.bonus_points

    if points && points > 0
      bonus_phrase = if points == 1
                       "1 bonus point"
                     else
                       "#{points} bonus points"
                     end

      "Congratulations! You've earned #{bonus_phrase} for completing a game piece."
    else
      "Congratulations! You've completed a game piece."
    end
  end

  protected

end
