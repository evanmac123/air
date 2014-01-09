class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user, polymorphic: true
  belongs_to :referring_user, :class_name => "User"
  belongs_to :rule
  belongs_to :rule_value
  belongs_to :demo
  has_one :goal, :through => :rule

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
    self.demo_id ||= user.demo_id
  end

  after_create do
    user.update_last_acted_at
    user.update_points(points, self.creation_channel) if points

    check_goal_completion

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
    self.inherent_points || self.rule.try(:points)
  end

  def post_act_summary
    if self.goal
      user.point_and_ticket_summary([self.goal.progress_text(user)])
    else
      user.point_and_ticket_summary
    end
  end

  def completes_goal?
    return false unless self.goal && self.goal.complete?(self.user)
    self.goal.acts.where(:user_id => self.user_id, :rule_id => self.rule_id).count == 1
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

  def self.displayable_to_user(viewing_user)
    unhidden.allowed_to_view_by_privacy_settings(viewing_user)
  end

  def self.allowed_to_view_by_privacy_settings(viewing_user)
    if viewing_user.is_site_admin
      # Site admins get to see anything they please.
      return where("1 = 1")
    end

    if viewing_user.is_guest?
      # And guests get to see their own only.
      return where(user_id: viewing_user.id, user_type: 'GuestUser')
    end

    friends = viewing_user.accepted_friends.where("users.privacy_level != 'nobody'")
    viewable_user_ids = friends.map(&:id) + [viewing_user.id]

    act_relation = where("acts.user_id IN (?) OR acts.privacy_level = 'everybody'", viewable_user_ids)
    # This is kind of a HACK, but fuck it, select_values is part of the 
    # public API.
    # TODO: write patch to Rails to do this properly, submit it, most likely
    # get it rejected. Or maybe not, who knows.

    act_relation.select_values = Array.wrap("DISTINCT \"acts\".*")
    act_relation
  end

  def self.parse(user_or_phone, body, options = {})
    set_return_message_type!(options)

    user, phone_number = extract_user_and_phone(user_or_phone)

    if user.nil?
      reply = Demo.number_not_found_response(options[:receiving_number])
      record_bad_message(phone_number, body)
      return parsing_error_message(reply)
    end

    value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').gsub(/\s+/, ' ')

    error = ensure_game_currently_running(user.demo)
    return error if error

    rule_value = user.first_eligible_rule_value(value)

    rule = rule_value.try(:rule)

    if rule
      reply, error_code = user.act_on_rule(rule, rule_value, :channel => options[:channel])
      if error_code == :success
        return parsing_success_message(reply)
      else
        return parsing_error_message(reply)
      end
    else
      reply = find_and_record_rule_suggestion(value, user)
      record_bad_message(phone_number, body, reply)
      return parsing_error_message(reply)
    end
  end

  def self.find_and_record_rule_suggestion(attempted_value, user)
    reply, last_suggested_item_ids = RuleValue.suggestion_for(attempted_value, user)
    
    user.last_suggested_items = last_suggested_item_ids if last_suggested_item_ids
    user.save!

    reply
  end

  def self.record_act(user, rule, rule_value, options={})
    channel = options[:channel]
    referring_user = options[:referring_user]
    suggestion_code = options[:suggestion_code]
                      
    text = rule.to_s
    if referring_user
      text += I18n.translate(
        'activerecord.models.act.thanks_from_referred_user',
        :default => " (thanks %{name} for the referral)",
        :name    => referring_user.name
      )
    end

    act = create!(:user => user, :text => text, :rule => rule, :rule_value => rule_value, :referring_user => referring_user, :creation_channel => (channel || ''), :suggestion_code => suggestion_code)

    [rule.reply, act.post_act_summary].join
  end

  def self.for_profile(viewing_user, _offset=0)
    in_demo(viewing_user.demo).displayable_to_user(viewing_user).recent(10).offset(_offset)
  end

  protected

  def schedule_mixpanel_ping
    unless user.name == Tutorial.example_search_name 
      Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("acted", data_for_mixpanel)
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
    }.merge(self.user.data_for_mixpanel)
  end

  def check_goal_completion
    if self.completes_goal?
      OutgoingMessage.send_side_message(user, self.goal.completion_sms_text, :channel => self.creation_channel)
      GoalCompletion.create!(:user => user, :goal => self.goal)
    end
  end

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

  def self.ensure_game_currently_running(demo)
    if demo.game_not_yet_begun?
      return parsing_error_message(demo.game_not_yet_begun_response)
    end

    if demo.game_over?
      return parsing_error_message(demo.game_over_response)
    end
  end

  def self.done_today
    where("created_at BETWEEN ? AND ?", Date.today.midnight, Date.tomorrow.midnight)
  end
end
