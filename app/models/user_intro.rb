class UserIntro < ActiveRecord::Base
  belongs_to :userable, polymorphic: true

  def display_first_tile_hint?
    self.displayed_first_tile_hint == false && userable.tile_completions.count == 0
  end

  def check_display_first_tile_hint
    unless self.displayed_first_tile_hint
      self.update_attribute("displayed_first_tile_hint", true)
    end
  end
end
