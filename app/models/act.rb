class Act < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule

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
    @return_message_type = options.delete(:return_message_type)

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

    # TODO: perhaps move this to SpecialCommand
    
    if value == "help"
      # record this somewhere
      return parsing_success_message('Earn points, text: "went to gym", "ate fruit", "ate vegetables", "walked stairs", "ran outside", "walked outside" - provided you did those things, of course.')
    end

    if user.demo.game_over?
      return parsing_success_message("Thanks for playing! The game is now over. If you'd like more information e-mailed to you, please text MORE INFO.")
    end

    rule = Rule.in_same_demo_as(user).where(:value => value).first

    if rule.nil? && value
      value_tokens = value.split(' ')
      referring_user_sms_slug = value_tokens.pop
      truncated_value = value_tokens.join(' ')

      rule = Rule.in_same_demo_as(user).where(:value => truncated_value).first
      referring_user = User.find_by_sms_slug(referring_user_sms_slug)
      if (rule && !referring_user)
        return parsing_error_message("We understood what you did, but not the user who referred you. Perhaps you could have them check their unique ID with the myid command?")
      end

      if referring_user == user
        return parsing_error_message("Now now. It wouldn't be fair to try to get extra points by referring yourself.")
      end
    end

    if rule
      reply, error_code = user.act_on_rule(rule, referring_user)
      if error_code == :success
        return parsing_success_message(reply)
      else
        return parsing_error_message(reply)
      end
    else 
      suggestion_phrase = Rule.find_and_record_rule_suggestion(value, user)

      if suggestion_phrase
        reply = "I didn't quite get what you meant. Maybe try #{suggestion_phrase}? Or text S to suggest we add what you sent."
        record_bad_message(phone_number, body, reply)
      else
        reply = "Sorry, I don't understand what that means. Text S to suggest we add what you sent."
        record_bad_message(phone_number, body)
      end

      return parsing_error_message(reply)
    end
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


  private

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

  def self.record_bad_message(phone_number, body, reply = '')
    BadMessage.create!(:phone_number => phone_number, :body => body, :received_at => Time.now, :automated_reply => reply)
  end
end
