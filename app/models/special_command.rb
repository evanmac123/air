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
end
