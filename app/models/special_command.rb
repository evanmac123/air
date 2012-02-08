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
    when 'follow', 'connect', 'fan'
      self.follow(user, args.first)
    when 'myid'
      self.myid(user)
    when 'moreinfo', 'more'
      self.moreinfo(user)
    when 's', 'suggest'
      self.suggestion(user, args)
    when Survey::SURVEY_ANSWER_PATTERN
      self.respond_to_survey(user, command_name)
    when /^[a-z]$/
      self.use_suggested_item(user, command_name)
    when 'lastquestion'
      self.remind_last_question(user)
    when 'rankings', 'ranking', 'standing', 'standings'
      self.send_rankings_page(user, :use_offset => false, :reset_offset => true)
    when 'morerankings'
      self.send_rankings_page(user)
    when 'help'
      self.send_help_response(user)
    when 'support'
      self.request_support(user)
    when 'survey', 'ur2cents', '2ur2cents'
      self.send_next_survey_question(user)
    when 'yes'
      self.accept_follower(user, args.first)
    when 'no'
      self.ignore_follow_request(user, args.first)
    when 'prizes'
      self.send_demo_prize_message(user.demo)
    when 'rules', 'commands'
      self.send_command_response
    when 'mute'
      self.mute_user(user)
    when 'gotit', 'got'
      self.suppress_mute_notice(user)
    else
      self.attempt_credit_game_referrer(user, command_name)
    end
  end

  private

  def self.follow(user_following, sms_slug_to_follow)
    user_to_follow = User.claimed.where(:sms_slug => sms_slug_to_follow, :demo_id => user_following.demo_id).first

    return parsing_error_message("Sorry, we couldn't find a user with the username #{sms_slug_to_follow}.") unless user_to_follow

    return parsing_error_message("Sorry, you can't follow yourself.") if user_following.id == user_to_follow.id

    Friendship.transaction do
      return parsing_success_message("You've already asked to be a fan of #{user_to_follow.name}.") if user_following.pending_friends.where('friendships.friend_id' => user_to_follow.id).present?

      return parsing_success_message("You're already a fan of #{user_to_follow.name}.") if user_following.accepted_friends.where('friendships.friend_id' => user_to_follow.id).present?

      return nil unless user_following.befriend(user_to_follow)
    end

    user_to_follow.follow_requested_message
  end

  def self.bad_friendship_index_error_message(user, request_index)
    if request_index && Friendship.pending(user).present?
      parsing_error_message("Looks like you already responded to that request, or didn't have a request with that number")
    else
      parsing_error_message("You have no pending requests from anyone to be a fan.")      
    end
  end

  def self.accept_follower(user, request_index=nil)
    friendship_to_accept = Friendship.pending(user, request_index).first

    unless friendship_to_accept
      return bad_friendship_index_error_message(user, request_index)
    end

    friendship_to_accept.accept
  end

  def self.ignore_follow_request(user, request_index = nil)
    friendship_to_ignore = Friendship.pending(user, request_index).first

    unless friendship_to_ignore
      return bad_friendship_index_error_message(user, request_index)
    end

    friendship_to_ignore.ignore
  end

  def self.myid(user)
    parsing_success_message("Your username is #{user.sms_slug}.")
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

  def self.use_suggested_item(user, letter_code)
    chosen_index = letter_code.ord - 'a'.ord
    suggested_item_indices = user.last_suggested_items.split('|')
    return nil unless suggested_item_indices.length > chosen_index

    rule_value = RuleValue.find(suggested_item_indices[chosen_index])
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
      parsing_success_message(survey.all_answers_already_message)
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

  def self.attempt_credit_game_referrer(referred_user, referring_user_sms_slug)
    demo = referred_user.demo
    return nil unless demo.credit_game_referrer_threshold && demo.game_referrer_bonus

    referring_user = demo.users.find_by_sms_slug(referring_user_sms_slug)
    return nil unless referring_user

    if referring_user == referred_user
      return parsing_error_message(I18n.t(
        'special_command.credit_game_referrer.cannot_refer_yourself_sms', 
        :default => "You've already claimed your account, and have %{points}. If you're trying to credit another user, @{say} their Username",
        # for some reason, pluralize works in development but not staging
        # or production
        :points => referred_user.points.to_s + ' ' + (referred_user.points == 1 ? 'point' : 'points')
      ))
    end

    referral_deadline = referred_user.accepted_invitation_at + demo.credit_game_referrer_threshold.minutes 
    if Time.now > referral_deadline
      return parsing_error_message(I18n.t('special_command.credit_game_referrer.too_late_for_game_referral_sms', :default => 'Sorry, the time when you can credit someone for referring you to the game is over.'))
    end

    if referred_user.game_referrer
      return parsing_error_message(I18n.t('special_command.credit_game_referrer.already_referred', :default => "You've already told us that %{referrer_name} referred you to the game.", :referrer_name => referred_user.game_referrer.name))
    end

    # If we make it here, we finally know it's OK to credit the referring user.

    credit_game_referrer(referred_user, referring_user)
  end

  def self.credit_game_referrer(referred_user, referring_user)
    demo = referred_user.demo

    referrer_act_text = I18n.t('special_command.credit_game_referrer.activity_feed_text', :default => "got credit for referring %{referred_name} to the game", :referred_name => referred_user.name)
    referrer_sms_text = I18n.t('special_command.credit_game_referrer.referrer_sms', :default => "%{referred_name} gave you credit for referring them to the game. Many thanks and %{points} bonus points!", :referred_name => referred_user.name, :points => demo.game_referrer_bonus)

    referred_act_text = I18n.t('special_command.credit_game_referrer.referred_activity_feed_text', :default => "credited %{referrer_name} for referring them to the game", :referrer_name => referring_user.name)
    referred_sms_points_phrase = case demo.referred_credit_bonus
                                 when nil: ""
                                 when 1: " (and 1 point)"
                                 else
                                   " (and #{demo.referred_credit_bonus} points)"
                                 end
    referred_sms_text = I18n.t('special_command.credit_game_referrer.referred_sms', :default => "Got it, %{referrer_name} referred you to the game. Thanks%{points_phrase} for letting us know.", :referrer_name => referring_user.name, :points_phrase => referred_sms_points_phrase)

    referred_user.update_attribute(:game_referrer_id, referring_user.id)

    referring_user.acts.create!(
      :text            => referrer_act_text,
      :inherent_points => demo.game_referrer_bonus
    )

    referred_user.acts.create!(
      :text            => referred_act_text,
      :inherent_points => demo.referred_credit_bonus
    )

    SMS.send_message(referring_user, referrer_sms_text)

    parsing_success_message(referred_sms_text)
  end

  def self.send_help_response(user)
    parsing_success_message(user.demo.help_response)
  end

  def self.request_support(user)
    user.send_support_request
    parsing_success_message("Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open.")
  end

  def self.send_next_survey_question(user)
    survey = Survey.open.where(:demo_id => user.demo_id).first

    unless survey.present?
      return parsing_error_message("Sorry, there is not currently a survey open.")
    end

    question = survey.latest_question_for(user)
    if question
      parsing_success_message(survey.latest_question_for(user).text)
    else
      parsing_success_message(survey.all_answers_already_message)
    end
  end

  def self.send_demo_prize_message(demo)
    parsing_success_message(demo.prize_message)
  end

  def self.send_command_response
    # We have this "help_command_explanation" interpolation because we want to
    # leave it out of email entirely, so we use channel_specific_translations
    # to stick it back into SMS and web replies.

    parsing_success_message("FAN [someone's ID] - become a fan (ex: \"fan bob12\")\nMYID - see your ID\nRANKING - see scoreboard\n@{help_command_explanation}PRIZES - see what you can win")
  end

  def self.mute_user(user)
    user.mute_for_now
    parsing_success_message("OK, you won't get any more texts from us for at least 24 hours.")
  end

  def self.suppress_mute_notice(user)
    user.update_attributes(:suppress_mute_notice => true)
    parsing_success_message("OK, we won't remind you about the MUTE command henceforth.")
  end
end
