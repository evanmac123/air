class Act < ActiveRecord::Base
  belongs_to :user
  belongs_to :rule

  after_create do
    user.update_points(rule.points)
  end

  def self.recent(limit)
    order('created_at desc').limit(limit)
  end

  def self.parse(from, body)
    user = User.find_by_phone_number(from)
    if user.nil?
      return "You haven't been invited to the game."
    end

    key_name, value = body.downcase.split(' ', 2)

    if key_name == "help"
      return "Score points by texting us your latest act. The format is: key value"
    end

    if key = Key.where(:name => key_name).first
      if rule = Rule.where(:key_id => key.id, :value => value).first
        create(:user => user, :text => body.downcase, :rule => rule)
        return rule.reply
      else
        good_value = key.rules.first.value
        return "Bad value for that key. Try: #{key_name} #{good_value}"
      end
    else
      return "We didn't understand. Try: help"
    end
  end
end
