class Act < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule

  after_create do
    user.update_points(rule.points) if rule
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

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
      record_bad_message(nil, phone_number, body)
      return parsing_error_message("I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\").")
    end

    key_name, value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').split(' ', 2)

    if key_name == "help"
      # record this somewhere
      return parsing_success_message('Earn points, text: "went to gym", "ate fruit", "ate vegetables", "walked stairs", "ran outside", "walked outside" - provided you did those things, of course.')
    end

    rule = if value.nil?
             find_coded_rule(key_name)
           else
             find_regular_rule(key_name, value)
           end

    if rule
      if rule.user_hit_limit?(user)
        return parsing_error_message("Sorry, you've already done that action.")
      else
        return parsing_success_message(record_act(user, rule))
      end
    elsif helpful_error_message = generate_helpful_error(key_name, value)
      return parsing_error_message(helpful_error_message)
    else
      record_bad_message(user, phone_number, body)
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

  def self.record_act(user, rule)
    create(:user => user, :text => rule.to_s, :rule => rule)

    reply = rule.reply
    if (victory_threshold = user.demo.victory_threshold)
      reply += " Points #{user.points}/#{victory_threshold}, r"
    else
      reply += " R"
    end

    reply += "ank #{user.ranking}/#{user.demo.users.ranked.count}."

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

  def self.record_bad_message(user, phone_number, body)
    BadMessage.create!(:user => user, :phone_number => phone_number, :body => body, :received_at => Time.now)
  end
end
