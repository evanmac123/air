class Act < ActiveRecord::Base
  include DemoScope
  extend ParsingMessage

  belongs_to :user
  belongs_to :rule
  belongs_to :demo

  before_create do
    self.demo_id ||= user.demo_id
  end

  after_create do
    user.update_points(points) if points
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

  def points
    self.inherent_points || self.rule.try(:points)
  end

  def self.recent(limit)
    order('created_at desc').limit(limit)
  end

  def self.parse(user_or_phone, body, options = {})
    set_return_message_type!(options)

    if user_or_phone.kind_of?(User)
      user = user_or_phone
      phone_number = user.phone_number
    else
      user = User.find_by_phone_number(user_or_phone)
      phone_number = user_or_phone
    end

    if user.nil?
      reply = "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."
      record_bad_message(phone_number, body)
      return parsing_error_message(reply)
    end

    value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').gsub(/\s+/, ' ')

    if user.demo.game_not_yet_begun?
      return parsing_success_message("The game will begin #{user.demo.begins_at.winning_time_format}. Please try again after that time.")
    end

    if user.demo.game_over?
      return parsing_success_message("Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO.")
    end

    rule_value = user.first_eligible_rule_value(value)

    if rule_value.nil? && value
      value_tokens = value.split(' ')
      referring_user_sms_slug = value_tokens.pop
      truncated_value = value_tokens.join(' ')

      rule_value = user.first_eligible_rule_value(truncated_value)
      referring_user = User.find_by_sms_slug(referring_user_sms_slug)
      if (rule_value && !referring_user)
        return parsing_error_message("We understood what you did, but not the user who referred you. Perhaps you could have them check their unique ID with the myid command?")
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
      if reply = find_and_record_rule_suggestion(value, user)
        record_bad_message(phone_number, body, reply)
      else
        reply = I18n.t(
          'activerecord.models.act.parse.no_suggestion_sms',
          :default => "Sorry, I don't understand what that means. \%{say} \"s\" to suggest we add what you sent."
        )
        record_bad_message(phone_number, body)
      end

      return parsing_error_message(reply)
    end
  end

  def self.find_and_record_rule_suggestion(attempted_value, user)
    matches = RuleValue.suggestible_for(attempted_value, user)

    begin
      # Note that the % in %{say} is escaped: we're going to re-interpolate
      # this later at the level that knows by what method (flash or SMS) we're
      # replying.

      result = I18n.t(
        'activerecord.models.rule_value.suggestion_sms',
        :default => "I didn't quite get that. %%{say} %{suggestion_phrase}, or \"s\" to suggest we add what you sent.",
        :suggestion_phrase => suggestion_phrase(matches)
      )
      matches.pop if result.length > 160
    end while (matches.present? && result.length > 160) 

    return nil if matches.empty?

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

    create(:user => user, :text => text, :rule => rule)

    reply = [rule.reply, user.point_and_ranking_summary].join(' ')

    reply
  end


  private

  def self.record_bad_message(phone_number, body, reply = '')
    BadMessage.create!(:phone_number => phone_number, :body => body, :received_at => Time.now, :automated_reply => reply)
  end
end
