class Act < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule

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
    @return_message_type = options.delete(:return_message_type)

    if user_or_phone.kind_of?(User)
      user = user_or_phone
      phone_number = user.phone_number
    else
      user = User.find_by_phone_number(user_or_phone)
      phone_number = user_or_phone
    end

    if user.nil?
      record_bad_message(phone_number, body)
      return parsing_error_message("I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\").")
    end

    key_name, value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').gsub(/\s+/, ' ').split(' ', 2)

    # TODO: perhaps move this to SpecialCommand
    
    if key_name == "help"
      # record this somewhere
      return parsing_success_message('Earn points, text: "went to gym", "ate fruit", "ate vegetables", "walked stairs", "ran outside", "walked outside" - provided you did those things, of course.')
    end

    if user.demo.game_over?
      return parsing_success_message("Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO.")
    end

    rule = look_up_rule_by_key_and_value(key_name, value)

    if rule.nil? && value
      value_tokens = value.split(' ')
      referring_user_sms_slug = value_tokens.pop
      truncated_value = value_tokens.join(' ')

      rule = look_up_rule_by_key_and_value(key_name, truncated_value)
      referring_user = User.find_by_sms_slug(referring_user_sms_slug)
      if (rule && !referring_user)
        return parsing_error_message("We understood what you did, but not the user who referred you. Perhaps you could have them check their unique ID with the myid command?")
      end

      if referring_user == user
        return "Now now. It wouldn't be fair to try to get extra points by referring yourself."
      end
    end

    if rule
      if rule.user_hit_limit?(user)
        return parsing_error_message("Sorry, you've already done that action.")
      else
        credit_referring_user(referring_user, user, rule)
        return parsing_success_message(record_act(user, rule, referring_user))
      end
    elsif helpful_error_message = generate_helpful_error(key_name, value)
      return parsing_error_message(helpful_error_message)
    else
      record_bad_message(phone_number, body)
      return parsing_error_message("We didn't understand. Try: help")
    end
  end


  private

  def self.find_coded_rule(key_name)
    CodedRule.where('value ILIKE ?', key_name).first
  end

  def self.find_regular_rule(key_name, value)
    if key = Key.where(:name => key_name).first
      Rule.where(:key_id => key.id, :value => value).first
    end
  end

  def self.generate_helpful_error(key_name, value)
    ## TODO: record this somewhere
    return nil unless value && key = Key.find_by_name(key_name)
    good_value = key.rules.first.value
    return "We understand #{key_name} but not #{value}. Try: #{key_name} #{good_value}"
  end

  def self.record_act(user, rule, referring_user = nil)
    text = rule.to_s
    if referring_user
      text += " (thanks #{referring_user.name} for the referral)"
    end

    create(:user => user, :text => text, :rule => rule)

    reply = [rule.reply, user.point_and_ranking_summary].join(' ')

    reply
  end

  def self.parsing_error_message(message)
    parsing_message(message, :failure)
  end

  def self.parsing_success_message(message)
    parsing_message(message, :success)
  end

  def self.parsing_message(message, message_type)
    if @return_message_type
      [message, message_type]
    else
      message
    end
  end

  def self.record_bad_message(phone_number, body)
    BadMessage.create!(:phone_number => phone_number, :body => body, :received_at => Time.now)
  end

  def self.look_up_rule_by_key_and_value(key_name, value)
    if value.nil?
      find_coded_rule(key_name)
    else
      find_regular_rule(key_name, value)
    end
  end

  def self.credit_referring_user(referring_user, referred_user, rule)
    return unless referring_user

    Act.create!(
      :user => referring_user,
      :text => "told #{referred_user.name} about the #{rule.full_name} command",
      :inherent_points => (rule.referral_points) || (rule.points / 2)
    )

    sms_text = "Thanks for referring #{referred_user.name} to the #{rule.full_name} command. " + referring_user.point_and_ranking_summary
    SMS.send(referring_user.phone_number, sms_text)
  end
end
