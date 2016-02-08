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
end
