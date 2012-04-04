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



  def self.example_search_name
    "Kermit the Frog"
  end
  
  def self.seed_example_user(demo)
    a = User.where(:demo_id => demo.id, :name => example_search_name)
    if a.empty?
      email = example_search_name.gsub(" ", "").downcase + demo.id.to_s + "@hengage.com"
      b = User.create!(:name => example_search_name, :demo_id => demo.id, 
          :email => email, :accepted_invitation_at => Time.now)
    end
  end
      
end
