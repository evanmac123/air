class Act < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule

  after_create do
    user.update_points(rule.points)
  end

  scope :recent, lambda {|max| order('created_at DESC').limit(max)}

  def self.recent(limit)
    order('created_at desc').limit(limit)
  end

  def self.parse(user, body, options = {})
    @return_message_type = options.delete(:return_message_type)

    if user.nil?
      # record this somewhere
      return parsing_error_message("You haven't been invited to the game.")
    end

    key_name, value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').split(' ', 2)

    if key_name == "help"
      # record this somewhere
      return parsing_success_message("Score points by texting this number your latest lifestyle act. Examples: ate a banana, smoked a cigarette, played basketball")
    end

    rule = if value.nil?
             find_coded_rule(key_name)
           else
             find_regular_rule(key_name, value)
           end

    if rule
      return parsing_success_message(record_act(user, rule))
    elsif helpful_error_message = generate_helpful_error(key_name, value)
      return parsing_error_message(helpful_error_message)
    else
      # TODO: record this somewhere
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
      reply += " You have #{user.points} out of #{victory_threshold} points."
    end

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
end
