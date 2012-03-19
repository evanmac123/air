class Tutorial < ActiveRecord::Base
  belongs_to :user

  
  def bump_step
    self.current_step += 1
    self.save
  end
  
  def back_up_a_step
    self.current_step -= 1
    self.save
  end

  def act_completed_since_tutorial_start
    acts = Act.where(:user_id => self.user.id, :creation_channel => "web")
    acts = acts.where('created_at > ?', self.created_at)
    acts.present?
  end
  
  def friend_followed_since_tutorial_start
    friendships = Friendship.where(:user_id => self.user.id)
    friendships = Friendship.where('created_at > ?', self.created_at)
    friendships.present?
  end
    
end
