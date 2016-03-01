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
    if self.explore_preview_copy_seeen
      false
    else
      self.explore_preview_copy_seeen = true
      self.save
    end
  end
end
