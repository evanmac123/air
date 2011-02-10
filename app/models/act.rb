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

    key_name, value = body.downcase.gsub(/\.$/, '').split(' ', 2)

    if key_name == "help"
      # record this somewhere
      return "Score points by texting this number your latest lifestyle act. Examples: ate a banana, smoked a cigarette, played basketball"
    end

    if key = Key.where(:name => key_name).first
      if rule = Rule.where(:key_id => key.id, :value => value).first
        create(:user => user, :text => body.downcase, :rule => rule)
        return rule.reply
      else
        # record this somewhere
        good_value = key.rules.first.value
        return "We understand #{key_name} but not #{value}. Try: #{key_name} #{good_value}"
      end
    else
      # record this somewhere
      return "We didn't understand. Try: help"
    end
  end
end
