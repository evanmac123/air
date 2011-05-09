module SpecialCommand
  def self.parse(from, text)
    normalized_command = text.strip.downcase.gsub(/\s+/, ' ')
    command_name, *args = normalized_command.split

    case command_name
    when 'follow', 'connect'
      self.follow(from, args.first)
    when 'myid'
      self.myid(from)
    when 'moreinfo', 'more'
      self.moreinfo(from)
    when 's', 'suggest'
      self.suggestion(from, args)
    when 'meant'
      self.use_suggested_item(from, args.first)
    end
  end

  private

  def self.follow(number_following, sms_slug_to_follow)
    user_following = User.find_by_phone_number(number_following)
    return nil unless user_following

    user_to_follow = User.where(:sms_slug => sms_slug_to_follow, :demo_id => user_following.demo_id).first
    return "Sorry, we couldn't find a user with the unique ID #{sms_slug_to_follow}." unless user_to_follow

    return "You're already following #{user_to_follow.name}." if user_following.friendships.where(:friend_id => user_to_follow.id).first

    user_following.friendships.create(:friend_id => user_to_follow.id)
    "OK, you're now following #{user_to_follow.name}."
  end

  def self.myid(from)
    user = User.find_by_phone_number(from)
    return nil unless user
    "Your unique ID is #{user.sms_slug}."
  end

  def self.moreinfo(from)
    MoreInfoRequest.create!(
      :phone_number => from,
      :command      => 'moreinfo'
    )

    "Great, we'll be in touch. Stay healthy!"
  end

  def self.suggestion(from, words)
    user = User.find_by_phone_number(from)
    return nil unless user

    if words.empty?
      words = BadMessage.where(:phone_number => user.phone_number).order('created_at DESC').limit(1).first.body.split
    end

    if User.find_by_sms_slug(words.last)
      words.pop
    end

    Suggestion.create!(:user => user, :value => words.join(' '))
    "Thanks! We'll take your suggestion into consideration."
  end

  def self.use_suggested_item(from, item_index)
    user = User.find_by_phone_number(from)
    return nil unless user

    chosen_index = item_index.to_i
    suggested_item_indices = user.last_suggested_items.split('|')
    return nil unless suggested_item_indices.length >= chosen_index

    rule = Rule.find(suggested_item_indices[chosen_index - 1])
    (user.act_on_rule(rule)).first # throw away error code in this case
  end
end
