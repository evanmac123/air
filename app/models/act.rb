class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user, polymorphic: true
  belongs_to :referring_user, :class_name => "User"
  belongs_to :demo

  before_save do
    self.hidden = self.text.blank?

    # Privacy level is denormalized from user onto act in the interest of
    # making #allowed_to_view_by_privacy_settings more efficient. It was
    # killing our DB.
    self.privacy_level = user.privacy_level
    true
  end

  before_create do
    self.demo_id ||= user.demo.id
  end

  after_create do
    user.update_last_acted_at
    user.update_points(points, self.creation_channel) if points

    schedule_mixpanel_ping
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

  attr_accessor :incoming_sms_sid, :suggestion_code

  def user_with_guest_allowed
    if user_id == 0
      GuestUser.new({demo_id: demo_id})
    else
      user_without_guest_allowed
    end
  end
  alias_method_chain :user, :guest_allowed

  def points
    self.inherent_points || 0
  end

  def post_act_summary
    user.point_and_ticket_summary
  end

  def self.recent(limit)
    order('created_at desc').limit(limit)
  end

  def self.unhidden
    where(:hidden => false)
  end

  def self.same_demo(user)
    where(:demo_id => user.demo_id)
  end

  def self.displayable_to_user(viewing_user, board, limit, offset)
    if viewing_user.is_site_admin
      # Site admins get to see anything they please.
      return where(demo_id: board.id).limit(limit).offset(offset).order("created_at DESC")
    end

    if viewing_user.is_guest?
      # And guests get to see their own only.
      return where(demo_id: board.id, user_id: viewing_user.id, user_type: 'GuestUser').limit(limit).offset(offset).order("created_at DESC")
    end

    friends = viewing_user.accepted_friends.where("users.privacy_level != 'nobody'")
    viewable_user_ids = friends.pluck(:id) + [viewing_user.id]
    board.acts.where("hidden ='f' and (user_id in (?) or privacy_level='everybody')", viewable_user_ids).order("created_at desc").limit(limit).offset(offset)
  end

  def self.for_profile(viewing_user, _offset=0)
    displayable_to_user(viewing_user, viewing_user.demo, 10, _offset)
  end

  protected

  def schedule_mixpanel_ping
    unless user.name == Tutorial.example_search_name
      TrackEvent.ping('acted', data_for_mixpanel, self.user)
    end
  end

  def data_for_mixpanel
    {
      :time                  => Time.now,
      :tagged_user_id        => self.referring_user_id,
      :channel               => self.creation_channel,
      :suggestion_code       => self.suggestion_code
    }
  end

  def self.record_bad_message(phone_number, body, reply = '')
    BadMessage.create!(:phone_number => phone_number, :body => body, :received_at => Time.now, :automated_reply => reply)
  end

  def self.extract_user_and_phone(user_or_phone)
    if user_or_phone.kind_of?(User)
      user = user_or_phone
      phone_number = user.phone_number
    else
      user = User.find_by_phone_number(user_or_phone)
      phone_number = user_or_phone
    end

    [user, phone_number]
  end

  def self.done_today
    where("created_at BETWEEN ? AND ?", Date.today.midnight, Date.tomorrow.midnight)
  end
end
