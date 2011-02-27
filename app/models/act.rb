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

  def self.parse(from, body)
    user = User.find_by_phone_number(from)
    if user.nil?
      # record this somewhere
      return "You haven't been invited to the game."
    end

    key_name, value = body.downcase.gsub(/\.$/, '').gsub(/\s+$/, '').split(' ', 2)

    if key_name == "help"
      # record this somewhere
      return "Score points by texting this number your latest lifestyle act. Examples: ate a banana, smoked a cigarette, played basketball"
    end

    rule = if value.nil?
             find_coded_rule(key_name)
           else
             find_regular_rule(key_name, value)
           end

    if rule
      return record_act(user, rule)
    elsif error_message = generate_helpful_error(key_name, value)
      return error_message
    else
      # TODO: record this somewhere
      return "We didn't understand. Try: help"
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
end
