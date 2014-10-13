class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user, polymorphic: true
  belongs_to :referring_user, :class_name => "User"
  belongs_to :rule
  belongs_to :rule_value
  belongs_to :demo

  before_save do
    # if rule.description is blank, then act.text will be blank, and we will set it as hidden
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

    trigger_tiles
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

    # UGH. But there's not a straightforward way to do a UNION in ActiveRecord, 
    # and performance of a straightforward OR-ed query was getting poor.
    # OPTZ: Use the limit/offset trick to improve query of this still more
    find_by_sql(["SELECT acts.* FROM acts WHERE acts.demo_id = ? AND acts.hidden = 'f' AND acts.user_id IN (?) UNION \
                  SELECT acts.* FROM acts WHERE acts.demo_id = ? AND acts.hidden = 'f' AND acts.privacy_level = 'everybody' \
                  ORDER BY created_at DESC LIMIT ? OFFSET ?",
                  board.id, viewable_user_ids, board.id, limit, offset])
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
    _rule = self.try(:rule)

    secondary_tag_names = _rule ? _rule.tags.map(&:name).sort : []

    {
      :time                  => Time.now,
      :rule_value            => _rule.try(:primary_value).try(:value),
      :primary_tag           => _rule.try(:primary_tag).try(:name),
      :secondary_tags        => secondary_tag_names,
      :tagged_user_id        => self.referring_user_id,
      :channel               => self.creation_channel,
      :suggestion_code       => self.suggestion_code
    }
  end

  # OPTZ: Cut this and satisfy_tiles_by_rule
  def trigger_tiles
    self.user.satisfy_tiles_by_rule(self.rule_id, self.referring_user_id.present?)
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
