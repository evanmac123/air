class Tutorial < ActiveRecord::Base
  belongs_to :user
  after_create :tutorial_mixpanel_ping

  def bump_step
    self.current_step += 1
    self.save
    tutorial_mixpanel_ping
  end
  
  def back_up_a_step
    self.current_step -= 1
    self.save
  end
  
  def tutorial_mixpanel_ping(exit = false)
    user_of_tut = self.user
    slide_data = {:slide_reached => self.current_step }
    event_name = exit ? "exited_tutorial_manually" : "tutorial_advanced"
    
    mixpanel_details = slide_data.merge(user_of_tut.data_for_mixpanel)
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event(event_name, mixpanel_details)
    self
  end
  
  def end_it
    self.ended_at = Time.now
    self.save
    self.tutorial_mixpanel_ping(exit = true)   
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
    # Note: if you ever change this name, make sure you update his name in the database too,
    # so that the method Demo.tutorial_success can still figure out which friends are real and imaginary
    "Kermit the Frog"
  end
  
  def self.seed_example_user(demo)
    a = User.where(:demo_id => demo.id, :name => example_search_name)
    if a.empty?
      email = example_search_name.gsub(" ", "").downcase + demo.id.to_s + "@hengage.com"
      b = User.create!(:name => example_search_name, :demo_id => demo.id, 
          :email => email, :accepted_invitation_at => Time.now, :gender => 'male')
    end
  end
  
end
