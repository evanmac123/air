class GuestUser
  def initialize(demo_id)
    @demo_id = demo_id
  end

  def is_site_admin
    false
  end

  def is_guest?
    true
  end

  def demo
    unless @_demo.present?
      @_demo = Demo.find(@demo_id)
    end

    @_demo
  end

  def ping_page(*args)
  end

  def accepted_friends
    User.where("id IS NULL") # no friends, sucker
  end

  def on_first_login
    false
  end

  def tile_completions
    TileCompletion.where("id IS NULL")
  end

  def has_friends
    false
  end
 
  def name
    "Guest User"
  end

  def email
    "guest_user@example.com"
  end

  def to_param
    "guestuser"
  end

  def authorized_to?(page_class)
    false
  end

  def to_ticket_progress_calculator
    NullTicketProgressCalculator.new
  end

  def tickets
    0
  end

  def points
    0
  end

  def avatar
    User::NullAvatar.new
  end

  def self.model_name
    "User"
  end
end
