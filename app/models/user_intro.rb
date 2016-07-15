class UserIntro < ActiveRecord::Base
  belongs_to :user

  def show_explore_intro!
    if self.explore_intro_seen
      false
    else
      self.explore_intro_seen = true
      self.save
    end
  end

  def show_explore_preview_copy!
    if self.explore_preview_copy_seen
      false
    else
      self.explore_preview_copy_seen = true
      self.save
    end
  end

  def display_first_tile_hint?
    !self.displayed_first_tile_hint && !self.user.tile_completions.first.present?
  end

  def check_display_first_tile_hint
    unless self.displayed_first_tile_hint
      self.update_attribute("displayed_first_tile_hint", true)
    end
  end
end
