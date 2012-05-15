class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user
  belongs_to :referring_user, :class_name => "User"
  belongs_to :rule
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
    user.update_points(points, self.creation_channel) if points

    check_goal_completion
    check_timed_bonuses

    trigger_tasks
    schedule_mixpanel_ping
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

  attr_accessor :incoming_sms_sid, :suggestion_code

  def points
    self.inherent_points || self.rule.try(:points)
  end

  def post_act_summary
    if self.goal
      user.point_and_ranking_summary([self.goal.progress_text(user)])
    else
      user.point_and_ranking_summary
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
    #act_relation = joins("LEFT JOIN friendships AS permission_friendships ON permission_friendships.friend_id = acts.user_id").where("acts.user_id = ? OR acts.privacy_level = 'everybody' OR (acts.privacy_level = 'connected' AND permission_friendships.user_id = ? AND permission_friendships.state = 'accepted')", viewing_user.id, viewing_user.id)

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

    rule_value, referring_user, error = extract_rule_value_and_referring_user(user, value)
    return error if error
    if rule_value && rule_value.forbidden?
      return parsing_error_message("Sorry, that's not a valid command.")
    end

    rule = rule_value.try(:rule)

    if rule
      reply, error_code = user.act_on_rule(rule, rule_value, :channel => options[:channel], :referring_user => referring_user)
      if error_code == :success
        return parsing_success_message(reply)
      else
        return parsing_error_message(reply)
      end
    else
      reply = find_and_record_rule_suggestion(value, user)
      record_bad_message(phone_number, body, reply)
      user.schedule_rule_suggestion_mixpanel_ping
      return parsing_error_message(reply)
    end
  end

  def self.find_and_record_rule_suggestion(attempted_value, user)
    if user.demo.detect_bad_words(attempted_value)
      return I18n.t(
        'activerecord.models.act.parse.bad_words_detected',
        :default => "Sorry, I don't understand what that means."
      )
    end

    reply, last_suggested_item_ids = RuleValue.suggestion_for(attempted_value, user)
    
    user.last_suggested_items = last_suggested_item_ids if last_suggested_item_ids
    user.save!

    reply
  end

  def self.record_act(user, rule, options={})
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

    act = create!(:user => user, :text => text, :rule => rule, :referring_user => referring_user, :creation_channel => (channel || ''), :suggestion_code => suggestion_code)

    [rule.reply, act.post_act_summary].join
  end


  protected

  def schedule_mixpanel_ping
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event("acted", data_for_mixpanel)
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

  def check_timed_bonuses
    fulfillable_bonuses = TimedBonus.fulfillable_by(self.user)
    # Important to mark all of these fulfilled before we go creating more Acts
    # to avoid race conditions and other nasty situations
    fulfillable_bonuses.each {|fulfillable_bonus| fulfillable_bonus.update_attribute(:fulfilled, true)}

    fulfillable_bonuses.each do |fulfillable_bonus|
      Act.create!(
        :text            => '',  # doesn't appear in feed
        :user            => self.user,
        :inherent_points => fulfillable_bonus.points
      )

      OutgoingMessage.send_side_message(user, fulfillable_bonus.sms_response, :channel => self.creation_channel)
    end
  end

  def trigger_tasks
    self.user.satisfy_suggestions_by_rule(self.rule_id, self.creation_channel, self.referring_user_id.present?)
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

  def self.extract_rule_value_and_referring_user(user, value)
    rule_value = user.first_eligible_rule_value(value)
    error = nil

    if rule_value.nil? && value
      rule_value, referring_user = try_extracting_rule_value_with_referring_user(user, value)
      if (rule_value && !referring_user)
        error = parsing_error_message("We understood what you did, but not the user who referred you. Perhaps you could have them check their username with the MYID command?")
      end

      if referring_user == user
        error = parsing_error_message("Now now. It wouldn't be fair to try to get extra points by referring yourself.")
      end
    end

    [rule_value, referring_user, error]
  end

  def self.try_extracting_rule_value_with_referring_user(user, value)
    value_tokens = value.split(' ')
    referring_user_sms_slug = value_tokens.pop
    truncated_value = value_tokens.join(' ')

    rule_value = user.first_eligible_rule_value(truncated_value)
    referring_user = User.where(:sms_slug => referring_user_sms_slug, :demo_id => user.demo_id).first

    [rule_value, referring_user]
  end
end
