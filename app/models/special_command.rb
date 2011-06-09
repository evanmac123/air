module SpecialCommand
  extend ParsingMessage

  def self.parse(user_or_phone, text, options)
    set_return_message_type!(options)

    user = user_or_phone.kind_of?(User) ?
             user_or_phone :
             User.find_by_phone_number(user_or_phone)
    return nil unless user

    normalized_command = text.strip.downcase.gsub(/\s+/, ' ')
    command_name, *args = normalized_command.split

    case command_name
    when 'follow', 'connect'
      self.follow(user, args.first)
    when 'myid'
      self.myid(user)
    when 'moreinfo', 'more'
      self.moreinfo(user)
    when 's', 'suggest'
      self.suggestion(user, args)
    when 'meant'
      self.use_suggested_item(user, args.first)
    when /^\d+$/
      self.respond_to_survey(user, command_name)
    when 'lastquestion'
      self.remind_last_question(user)
    when 'rankings'
      self.send_rankings_page(user, :use_offset => false, :reset_offset => true)
    when 'morerankings'
      self.send_rankings_page(user)
    else
      self.credit_game_referrer(user, command_name)
    end
  end

  private

  def self.follow(user_following, sms_slug_to_follow)
    user_to_follow = User.where(:sms_slug => sms_slug_to_follow, :demo_id => user_following.demo_id).first
    return parsing_error_message("Sorry, we couldn't find a user with the unique ID #{sms_slug_to_follow}.") unless user_to_follow

    return parsing_success_message("You're already following #{user_to_follow.name}.") if user_following.friendships.where(:friend_id => user_to_follow.id).first

    user_following.friendships.create(:friend_id => user_to_follow.id)
    parsing_success_message("OK, you're now following #{user_to_follow.name}.")
  end

  def self.myid(user)
    parsing_success_message("Your unique ID is #{user.sms_slug}.")
  end

  def self.moreinfo(user)
    MoreInfoRequest.create!(
      :phone_number => user.phone_number,
      :command      => 'moreinfo'
    )

    parsing_success_message("Great, we'll be in touch. Stay healthy!")
  end

  def self.suggestion(user, words)
    if words.empty?
      words = BadMessage.where(:phone_number => user.phone_number).order('created_at DESC').limit(1).first.body.split
    end

    if User.find_by_sms_slug(words.last)
      words.pop
    end

    Suggestion.create!(:user => user, :value => words.join(' '))
    parsing_success_message("Thanks! We'll take your suggestion into consideration.")
  end

  def self.use_suggested_item(user, item_index)
    chosen_index = item_index.to_i
    suggested_item_indices = user.last_suggested_items.split('|')
    return nil unless suggested_item_indices.length >= chosen_index

    rule_value = RuleValue.find(suggested_item_indices[chosen_index - 1])
    parsing_success_message((user.act_on_rule(rule_value.rule, rule_value)).first) # throw away error code in this case
  end

  def self.respond_to_survey(user, choice)
    survey = user.open_survey
    return nil unless survey

    question = survey.latest_question_for(user)

    if question
      question.respond(user, survey, choice)
    else
      return nil if survey.demo.has_rule_value_matching?(choice) # Give Act.parse a crack at it
      parsing_success_message("Thanks, we've got all of your survey answers already.")
    end
  end

  def self.remind_last_question(user)
    survey = user.open_survey
    return parsing_error_message("You're not currently taking a survey") unless survey

    question = survey.latest_question_for(user)
    if question
      parsing_success_message("The last question was: #{question.text}")
    else
      parsing_success_message("You've already answered all of the questions in the survey.")
    end
  end

  def self.send_rankings_page(user, options={})
    user.short_rankings_page!(options)
  end

  def self.credit_game_referrer(user, referring_user_sms_slug)
    demo = user.demo
    return nil unless demo.credit_game_referrer_threshold && demo.game_referrer_bonus

    referral_deadline = user.accepted_invitation_at + demo.credit_game_referrer_threshold.minutes 
    if Time.now > referral_deadline
      return I18n.t('special_command.credit_game_referrer.too_late_for_game_referral_sms', :default => 'Sorry, the time when you can credit someone for referring you to the game is over.')
    end

    if referring_user_sms_slug == user.sms_slug
      return I18n.t('special_command.credit_game_referrer.cannot_refer_yourself_sms', :default => 'Nice try. But would it be fair to give you points for referring yourself?')
    end

    referring_user = demo.users.find_by_sms_slug(referring_user_sms_slug)
    return nil unless referring_user

    if user.game_referrer
      return I18n.t('special_command.credit_game_referrer.already_referred', :default => "You've already told us that %{referrer_name} referred you to the game.", :referrer_name => user.game_referrer.name)
    end

    # If we make it here, we finally know it's OK to credit the referring user.

    act_text = I18n.t('special_command.credit_game_referrer.activity_feed_text', :default => "got credit for referring %{referred_name} to the game", :referred_name => user.name)
    referrer_sms_text = I18n.t('special_command.credit_game_referrer.referrer_sms', :default => "%{referred_name} gave you credit for referring him to the game. Many thanks and %{points} bonus points!", :referred_name => user.name, :points => demo.game_referrer_bonus)
    referred_sms_text = I18n.t('special_command.credit_game_referrer.referred_sms', :default => "Got it, %{referrer_name} referred you to the game. Thanks for letting us know.", :referrer_name => referring_user.name)

    user.update_attribute(:game_referrer_id, referring_user.id)

    referring_user.acts.create!(
      :text            => act_text,
      :inherent_points => demo.game_referrer_bonus
    )

    SMS.send_message(referring_user.phone_number, referrer_sms_text)

    referred_sms_text
  end
end
