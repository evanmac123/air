class GuestUser < ActiveRecord::Base
  belongs_to :demo
  has_many :tile_completions, :as => :user, :dependent => :destroy
  has_many :acts, :as => :user, :dependent => :destroy

  def is_site_admin
    false
  end

  def is_guest?
    true
  end

  def ping_page(*args)
  end

  def accepted_friends
    User.where("id IS NULL") # no friends, sucker
  end

  def on_first_login
    false
  end

  def has_friends
    false
  end
 
  def name
    "Guest User"
  end

  def email
    "guest_user_#{id}@example.com"
  end

  def to_param
    "guestuser"
  end

  def authorized_to?(page_class)
    false
  end

  def to_ticket_progress_calculator
    User::TicketProgressCalculator.new(self)
  end

  def avatar
    User::NullAvatar.new
  end

  def flashes_for_next_request
    nil
  end

  def privacy_level
    'nobody'
  end

  def update_last_acted_at
  end

  def update_points(bump, *args)
    PointIncrementer.new(self, bump).update_points
  end

  def satisfy_tiles_by_rule(*args)
  end

  def data_for_mixpanel
    {}
  end

  def point_and_ticket_summary(prefix = [])
    User::PointAndTicketSummarizer.new(self).point_and_ticket_summary(prefix)
  end

  def to_guest_user_hash # used to persist this guest's information to the next request
    {
      :id => id
    }
  end
end
