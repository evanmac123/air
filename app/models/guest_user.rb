class GuestUser < ActiveRecord::Base
  # Q: Why is GuestUser not a subclass of User?
  # A: User is an overly fat model, and an old one, and I decided that some 
  # redundancy between GuestUser's and User's APIs was an OK cost to pay for
  # not dragging in a ton of old gnarly code from User.
  #
  # Plus, common behavior between this and User is good leverage to refactor
  # stuff out of User, which User could use.
  
  belongs_to :demo
  has_many   :tile_completions, :as => :user, :dependent => :destroy
  has_many  :completed_tiles, source: :tile, through: :tile_completions
  has_many   :acts, :as => :user, :dependent => :destroy
  has_one    :converted_user, :class_name => "User", :foreign_key => :original_guest_user_id, :inverse_of => :original_guest_user
  has_many   :user_in_raffle_infos, as: :user

  include CancelAccountToken
  include User::FakeUserBehavior

  def is_guest?
    true
  end

  def role
    "Guest"
  end

  def ping(event, properties={})
    data = data_for_mixpanel.merge(properties)
    TrackEvent.ping(event, data)
  end
 
  def name
    "Guest User [#{id}]"
  end

  def email
    "guest_user_#{id}@example.com"
  end

  def to_param
    "guestuser"
  end

  def to_ticket_progress_calculator
    User::TicketProgressCalculator.new(self)
  end

  def update_last_acted_at
    update_attributes(last_acted_at: Time.now)
  end

  def update_points(bump, *args)
    PointIncrementer.new(self, bump).update_points
  end

  def data_for_mixpanel
    {
      distinct_id:  "guest_user_#{self.id}",
      user_type:    self.highest_ranking_user_type,
      game:         self.demo.try(:name),
      is_test_user: is_test_user?
    }
  end

  def highest_ranking_user_type
    "guest"
  end

  def point_and_ticket_summary(prefix = [])
    User::PointAndTicketSummarizer.new(self).point_and_ticket_summary(prefix)
  end

  def to_guest_user_hash # used to persist this guest's information to the next request
    {
      :id => id
    }
  end

  def convert_to_full_user!(name, email, password, location_name = nil)
    converted_user = User.find_by_email(email)

    location_id = location_name.present? ? Location.where(name: location_name).where(demo_id: self.demo_id).pluck(:id).first : nil

    if converted_user && converted_user.unclaimed?
      #converted_user.demo_id = demo_id
      converted_user.name = name
      converted_user.email = email
      converted_user.points = points
      converted_user.tickets = tickets
      converted_user.get_started_lightbox_displayed = true
      converted_user.accepted_invitation_at = Time.now
      converted_user.characteristics = {}
    else
      converted_user = User.new(name: name, email: email, 
        points: points, tickets: tickets, get_started_lightbox_displayed: true, 
        accepted_invitation_at: Time.now, characteristics: {})
    end
    converted_user.password = converted_user.password_confirmation = password
    converted_user.original_guest_user = self
    converted_user.cancel_account_token = generate_cancel_account_token(converted_user)
    converted_user.last_acted_at = last_acted_at
    converted_user.voteup_intro_seen = voteup_intro_seen
    converted_user.share_link_intro_seen = share_link_intro_seen
    converted_user.location_id = location_id

    converted_user.converting_from_guest = true
    converted_user.must_have_location = true if location_name.present?

    if converted_user.save
      converted_user.add_board(demo_id, true)
      tile_completions.each {|tile_completion| tile_completion.user = converted_user; tile_completion.save!}
      acts.each {|act| act.user = converted_user; act.save!}
      UserInRaffleInfo.where(user_id: self.id, user_type: "GuestUser").each do |u_info|
        u_info.update_attributes(user_id: converted_user.id, user_type: "User")
      end
      converted_user.send_conversion_email
      converted_user
    else
      converted_user.errors.messages.each do |field, error_messages|
        self.errors.set(field, error_messages.uniq) # the #uniq gets rid of duplicate password errors
      end

      nil
    end
  end

  def accepted_invitation_at
    created_at
  end

  def slug
    "guestuser"
  end

  def can_start_over?
    tile_completions.first.present?
  end

  def not_show_all_completed_tiles_in_progress
    User::TileProgressCalculator.new(self).not_show_all_completed_tiles_in_progress
  end

  def voteup_intro_never_seen
    !(voteup_intro_seen)
  end

  def share_link_intro_never_seen
    !(share_link_intro_seen)
  end
end
