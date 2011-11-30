class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user
  belongs_to :rule
  belongs_to :demo
  has_one :goal, :through => :rule

  before_create do
    self.demo_id ||= user.demo_id
  end

  after_create do
    user.update_points(points) if points

    check_goal_completion
    check_timed_bonuses
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

  def points
    self.inherent_points || self.rule.try(:points)
  end

  def post_act_summary(points_denominator)
    if self.goal
      user.point_and_ranking_summary(points_denominator, [self.goal.progress_text(user)])
    else
      user.point_and_ranking_summary(points_denominator)
    end
  end

  def completes_goal?
    return false unless self.goal && self.goal.complete?(self.user)
    self.goal.acts.where(:user_id => self.user_id, :rule_id => self.rule_id).count == 1
  end

  def self.recent(limit)
    order('created_at desc').limit(limit)
  end

  def self.displayable
    where("text != ''")
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

    if user.demo.game_not_yet_begun?
      return parsing_success_message(user.demo.game_not_yet_begun_response)
    end

    if user.demo.game_over?
      return parsing_success_message(user.demo.game_over_response)
    end

    rule_value = user.first_eligible_rule_value(value)

    if rule_value.nil? && value
      rule_value, referring_user = extract_rule_value_and_referring_user(user, value)
      if (rule_value && !referring_user)
        return parsing_error_message("We understood what you did, but not the user who referred you. Perhaps you could have them check their user ID with the MYID command?")
      end

      if referring_user == user
        return parsing_error_message("Now now. It wouldn't be fair to try to get extra points by referring yourself.")
      end
    end

    if rule_value && rule_value.forbidden?
      return parsing_error_message("Sorry, that's not a valid command.")
    end

    rule = rule_value.try(:rule)

    if rule
      reply, error_code = user.act_on_rule(rule, rule_value, referring_user)
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
    matches = RuleValue.suggestible_for(attempted_value, user)

    begin
      result = I18n.t(
        'activerecord.models.rule_value.suggestion_sms',
        :default => "I didn't quite get that. @{Say} %{suggestion_phrase}, or \"s\" to suggest we add what you sent.",
        :suggestion_phrase => suggestion_phrase(matches)
      )
      matches.pop if result.length > 160
    end while (matches.present? && result.length > 160) 

    if matches.empty?
      return I18n.t(
        'activerecord.models.act.parse.no_suggestion_sms',
        :default => "Sorry, I don't understand what that means. @{Say} \"s\" to suggest we add what you sent."
      )
    end

    user.last_suggested_items = matches.map(&:id).map(&:to_s).join('|')
    user.save!

    result
  end

  def self.suggestion_phrase(matches)
    # Why is there no #map_with_index? Srsly.

    alphabet = ('a'..'z').to_a
    match_index = 0
    match_strings = matches.map do |match| 
      letter = alphabet[match_index]
      substring = "\"#{letter}\" for \"#{match.value}\""
      match_index += 1
      substring
    end

    match_strings.join(', ')
  end

  def self.record_act(user, rule, referring_user = nil)
    text = rule.to_s
    if referring_user
      text += I18n.translate(
        'activerecord.models.act.thanks_from_referred_user',
        :default => " (thanks %{name} for the referral)",
        :name    => referring_user.name
      )
    end

    points_denominator_before_act = user.points_denominator
    act = create!(:user => user, :text => text, :rule => rule)

    [rule.reply, act.post_act_summary(points_denominator_before_act)].join(' ')
  end


  protected

  def check_goal_completion
    if self.completes_goal?
      SMS.send_side_message(user, self.goal.completion_sms_text)
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

      SMS.send_side_message(user, fulfillable_bonus.sms_response)
    end
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

  def self.extract_rule_value_and_referring_user(user, value)
    value_tokens = value.split(' ')
    referring_user_sms_slug = value_tokens.pop
    truncated_value = value_tokens.join(' ')

    rule_value = user.first_eligible_rule_value(truncated_value)
    referring_user = User.find_by_sms_slug(referring_user_sms_slug)

    [rule_value, referring_user]
  end
end
