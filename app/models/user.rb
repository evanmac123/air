require 'digest/sha1'

class User < ActiveRecord::Base
  # Maximum number of days back we will consider acts in the moving average
  # (counting today as day 0)
  MAX_RECENT_AVERAGE_HISTORY_DEPTH = 6

  DEFAULT_RANKING_CUTOFF = 15

  DEMOGRAPHIC_FIELD_NAMES = %w(gender date_of_birth).freeze

  PRIVACY_LEVELS = %w(everybody connected nobody).freeze

  GENDERS = ["female", "male", "other", nil].freeze

  DEFAULT_MUTE_NOTICE_THRESHOLD = 10

  FIELDS_TRIGGERING_SEGMENTATION_UPDATE = %w(characteristics points location_id date_of_birth height weight gender demo_id accepted_invitation_at)

  include Clearance::User
  include User::Ranking
  include User::Segmentation

  belongs_to :demo
  belongs_to :location
  belongs_to :game_referrer, :class_name => "User"
  has_many   :acts, :dependent => :destroy
  has_many   :friendships, :dependent => :destroy
  has_many   :friends, :through => :friendships
  has_many   :survey_answers
  has_many   :wins, :dependent => :destroy
  has_many   :goal_completions
  has_many   :completed_goals, :through => :goal_completions, :source => :goal
  has_many   :timed_bonuses, :class_name => "TimedBonus"
  has_many   :task_suggestions, :dependent => :destroy
  has_many   :tasks, :through => :task_suggestions
  has_and_belongs_to_many :levels
  has_one   :tutorial, :dependent => :destroy
  validate :normalized_phone_number_unique, :normalized_new_phone_number_unique
  
  validate :sms_slug_does_not_match_commands

  validates_uniqueness_of :slug, :if => :slug_required
  validates_uniqueness_of :sms_slug, :message => "Sorry, that username is already taken.", :if => :slug_required
  validates_uniqueness_of :overflow_email, :allow_blank => true

  validates_presence_of :name, :if => :name_required, :message => "Please enter your first and last name"
  validates_presence_of :sms_slug, :message => "Please choose a username", :if => :slug_required
  validates_presence_of :slug, :if => :slug_required
  
  validates_presence_of :privacy_level
  validates_inclusion_of :privacy_level, :in => PRIVACY_LEVELS

  validates_inclusion_of :gender, :in => GENDERS

  validates_format_of :slug, :with => /^[0-9a-z]+$/, :if => :slug_required
  validates_format_of :sms_slug, :with => /^[0-9a-z]{2,}$/, :if => :slug_required,
                      :message => "Sorry, the username must consist of letters or digits only."

  validates_presence_of :demo_id
  validates_numericality_of :height, :allow_blank => true, :message => "Please use a numeric value for your height, and express it in inches"
  validates_numericality_of :weight, :allow_blank => true, :message => "Please use a numeric value for your weight, and express it in pounds"

  validates_acceptance_of :terms_and_conditions, :if => :trying_to_accept, :message => "You must accept the terms and conditions" 

  validates_length_of :password, :minimum => 6, :allow_blank => true, :message => 'must have at least 6 characters'
  validates :email, :with => :email_distinct_from_all_overflow_emails 
  validates :overflow_email, :with => :overflow_email_distinct_from_all_emails 


  has_attached_file :avatar,
    :styles => {:thumb => ["96x96#", :png]},
    :default_style => :thumb,
    #:processors => [:png],
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_protocol => 'https',
    :path => "/avatars/:id/:style/:filename",
    :bucket => S3_AVATAR_BUCKET

  serialize :flashes_for_next_request
  serialize :characteristics

  before_validation do
    # NOTE: This method is only called when you actually CALL the create method
    # (Not when you ask if the method is valid :on => :create.)
    # creating a new object and testing x.valid? :on => :create does not send us to this function
    if slug_required
      unless trying_to_accept
        set_slugs_based_on_name if self.slug.blank? || self.sms_slug.blank?
      end
    end
  end


  before_validation do
    downcase_sms_slug if slug_required
  end

  before_create do
    set_invitation_code
  end

  before_update do
    schedule_update_demo_alltime_rankings if changed.include?('points')
    schedule_update_demo_recent_average_rankings if (!batch_updating_recent_averages && changed.include?('recent_average_points'))
    trigger_demographic_tasks
  end

  before_save do
    downcase_email
    cast_characteristics
    update_demo_ranked_user_count
  end

  after_create do
    suggest_first_level_tasks
    schedule_segmentation_create
  end

  after_update do
    schedule_segmentation_update
    update_associated_act_privacy_levels
  end

  after_destroy do
    destroy_friendships_where_secondary
    fix_demo_rankings
    decrement_demo_ranked_user_count
    destroy_segmentation_info
  end

  attr_reader :batch_updating_recent_averages

  attr_accessor :trying_to_accept, :password_confirmation
  attr_protected :is_site_admin, :invitation_method

  has_alphabetical_column :name

  def corporate_email
    return email if overflow_email.empty?
    overflow_email
  end
  
  def email_distinct_from_all_overflow_emails
    return if email.blank? && overflow_email.blank?
    if email.blank? && overflow_email.present?
      self.errors.add(:email, 'must have a primary email if you have a secondary email')
    elsif User.where(overflow_email: email).reject{|ff| ff == self}.present?
      self.errors.add(:email, 'someone else has your primary email as their secondary email')
    end
  end

  def overflow_email_distinct_from_all_emails
    return if overflow_email.blank? 
    if User.where(email: overflow_email).reject{|ff| ff == self}.present?
      self.errors.add(:overflow_email, 'someone else has your secondary email as their primary email')
    end
  end



  def sms_slug_does_not_match_commands
    special_commands = ['follow', 'connect', 'fan', 'friend', 'befriend', 'myid', 'moreinfo', 'more', 'suggest', 'lastquestion', 
      'rankings', 'ranking', 'standing', 'standings', 'morerankings', 'help', 'support', 'survey', 
      'ur2cents', '2ur2cents', 'yes', 'no', 'prizes', 'rules', 'commands', 'mute', 'gotit', 'got']
    if self.demo && self.demo.rule_values.present?
      demo_rules = self.demo.rule_values
      demo_rule_values = demo_rules.collect do |v|
        v.value
      end
    else
      demo_rule_values = []
    end
    
    all_commands = special_commands + demo_rule_values
    if all_commands.include? self.sms_slug
      self.errors.add("sms_slug", "Sorry, but that username is reserved")
    end
  end
  
  def her_him
    case self.gender
    when "female"
      return "her"
    when "male"
      return "him"
    else
      return "them"
    end
  end
  
  def her_his
    case self.gender
    when "female"
      return "her"
    when "male"
      return "his"
    else
      return "their"
    end
  end
  
  def can_see_activity_of(user)
    return true if self == user
    return true if self.is_site_admin
    case user.privacy_level
    when 'everybody'
      return true 
    when 'connected'
      return true if self.friends_with? user
    end
    return false
  end
  
  def reason_for_privacy
    case self.privacy_level
    when 'everybody'
      reason = " allows everyone to see their activity"
    when 'connected'
      reason = " only allows friends to see their activity"
    when 'nobody'
      reason = " does not allow anyone to see their activity"
    end
    return reason
  end
  
  def points_to_next_unachieved_threshold
    next_threshold = self.next_unachieved_threshold
    return nil if next_threshold.nil?
    next_threshold - self.points
  end
  
  module UpdatePasswordWithBlankForbidden
    def update_password(password)
      # See comment in user_spec for #update_password.
      unless password.present?
        self.errors.add :password, "Please choose a password"
        return false
      end

      super(password)
    end
  end

  include UpdatePasswordWithBlankForbidden
  
  def followers
    # You'd think you could do this with an association, and if you can figure
    # out how to get that to work, please, be my guest.

    self.class.joins("INNER JOIN friendships on users.id = friendships.user_id").where('friendships.friend_id = ?', self.id)
  end

  def accepted_followers
    followers.where('friendships.state' => 'accepted')
  end

  def pending_friends
    friends.where('friendships.state' => 'pending')
  end
  
  def initiated_friends
    friends.where('friendships.state' => 'initiated')
  end

  def accepted_friends
    friends.where('friendships.state' => 'accepted')
  end
  
  def accepted_friends_same_demo
    accepted_friends.where(:demo_id => self.demo_id)
  end

  def accepted_friends_not_counting_fairy_tale_characters
    accepted_friends.where('users.name != ?', Tutorial.example_search_name)
  end
  
  def friendship_pending_with(other)
    pending_friends.include?(other)
  end
  
  def friends_with?(other)
    self.relationship_with(other) == "friends"
  end
  
  def relationship_with(other)
    return "self" if self == other
    from_me   = Friendship.where(:user_id => self.id, :friend_id => other.id).first
    from_me_state = from_me ? from_me.state : nil
    from_them = Friendship.where(:friend_id => self.id, :user_id => other.id).first
    from_them_state = from_them ? from_them.state : nil
    
    if from_me.nil? && (from_them.nil?)
      return "none"
    elsif from_me_state == "initiated"
      return "a_initiated"
    elsif from_them_state == "initiated"
      return "b_initiated"
    elsif from_me_state == "accepted"
      return "friends"
    else
      return "unknown"
    end
  end
    
  # See comment by Demo#acts_with_current_demo_checked for an explanation of
  # why we do this.

  # Commenting this out until I can figure out to redo alias_method_chain with 'super'
  # %w(friends pending_friends accepted_friends followers accepted_followers).each do |base_method_name|
  #   class_eval <<-END_DEF
  #     def #{base_method_name}_with_in_current_demo
  #       #{base_method_name}_without_in_current_demo.where(:demo_id => self.demo_id)
  #     end
  # 
  #     #alias_method_chain :#{base_method_name}, :in_current_demo
  #   END_DEF
  # 
  # end

  def to_param
    slug
  end

  def short_rankings_page!(options={})
    more_rankings_prompt = I18n.t('activerecord.models.user.more_rankings_prompt', :default => 'Send MORERANKINGS for more.')

    _ranking_query_offset = !(options[:use_offset] == false) ? ranking_query_offset : nil
    rankings_strings = self.demo.users.for_short_ranking_page(_ranking_query_offset)

    if rankings_strings.empty?
      # back to the top
      self.ranking_query_offset = 0
      self.save!
      return I18n.translate('activerecord.models.user.end_of_rankings', :default => "That's everybody! Send RANKINGS to start over from the top.")
    end


    rankings_string = rankings_strings.join("\n")
    response = (rankings_strings + [more_rankings_prompt]).join("\n")

    while(rankings_strings.present? && response.length > 160)
      rankings_strings.pop
      response = (rankings_strings + [more_rankings_prompt]).join("\n")
    end

    if options[:reset_offset] || self.ranking_query_offset.nil?
      self.ranking_query_offset = 0
    end
    self.ranking_query_offset += rankings_strings.length
    self.save!

    response
  end

  def send_support_request
    latest_act_descriptions = IncomingSms.where(:from => self.phone_number).order("created_at DESC").limit(20).map(&:body)

    Mailer.delay.support_request(self.name, self.email, self.phone_number, self.demo.name, latest_act_descriptions)
  end

  def first_eligible_rule_value(value)
    matching_rule_values = RuleValue.visible_from_demo(self).where(:value => value)
    matching_rule_values.select{|rule_value| rule_value.not_forbidden?}.first || matching_rule_values.first
  end

  def generate_short_numerical_validation_token
    letters = "0234568"
    jumbled_letters = letters.split("").sort_by{rand}.join
    token = jumbled_letters[0,4]
    self.new_phone_validation = token
    self.save
  end

  def invitation_requested_via_sms?
    self.invitation_method == "sms"
  end

  def invitation_requested_via_email?
    self.invitation_method == "email"
  end

  def invitation_requested_via_web?
    self.invitation_method == "web"
  end

  def confirm_new_phone_number
    self.phone_number = self.new_phone_number
    self.new_phone_number = ""
    self.new_phone_validation = ""
  end

  def new_phone_number_needs_verification?
    new_phone_number.present?
  end

  def first_name
    name.split.first
  end

  def send_new_phone_validation_token
    OutgoingMessage.send_message self.new_phone_number, "Your code to verify this phone with H Engage is #{self.new_phone_validation}.", nil, :from_demo => self.demo
  end

  def validate_new_phone(entered_validation_code)
    entered_validation_code == self.new_phone_validation
  end

  def schedule_followup_welcome_message
    return if self.demo.followup_welcome_message.blank?
    #self.send_followup_welcome_message
    self.delay(:run_at => Time.now + demo.followup_welcome_message_delay.minutes).send_followup_welcome_message
  end

  def send_followup_welcome_message
    User.transaction do
      unless self.follow_up_message_sent_at
        OutgoingMessage.send_message(self, self.demo.followup_welcome_message)
        self.update_attributes(:follow_up_message_sent_at => Time.now)
      end
    end
  end

  def cancel_new_phone_number
    self.update_attributes(:new_phone_number => '', :new_phone_validation => '')
  end

  def bump_mt_texts_sent_today
    increment!(:mt_texts_today)
    if self.mt_texts_today == self.mute_notice_threshold && !(self.suppress_mute_notice)
      OutgoingMessage.send_message(self, "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT.")
    end
  end

  def notification_channels
    case self.notification_method
    when 'email'
      [:email]
    when 'sms'
      [:sms]
    when 'both'
      [:sms, :email]
    end
  end

  def reply_email_address(include_name = true)
    email_name, email_address = if self.demo.email
                    [self.demo.name, self.demo.email]
                  else
                    ['H Engage', 'play@playhengage.com']
                  end

    if include_name
      "#{email_name} <#{email_address}>"
    else
      email_address
    end
  end

  def top_level
    return nil if self.levels.empty?
    self.levels.order("threshold DESC").limit(1).first
  end

  def top_level_index
    self.top_level.try(:index_within_demo) || 1
  end

  def data_for_mixpanel
    {
      :distinct_id           => self.email,
      :id                    => self.id,
      :game                  => self.demo.name,
      :following_count       => Friendship.accepted.where(:user_id => self.id).count,
      :followers_count       => Friendship.accepted.where(:friend_id => self.id).count,
      :level_index           => self.top_level_index,
      :score                 => self.points,
      :account_creation_date => self.created_at.to_date,
      :joined_game_date      => self.accepted_invitation_at.try(:to_date),
      :location              => self.location.try(:name)
    }
  end

  def schedule_rule_suggestion_mixpanel_ping
    suggestion_ids = self.last_suggested_items.present? ? self.last_suggested_items.split('|') : []
    suggestion_hash = Hash[*([:suggestion_a, :suggestion_b, :suggestion_c].zip(suggestion_ids).flatten)]

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event("got rule suggestion", data_for_mixpanel.merge(suggestion_hash))
  end

  def self.in_canonical_ranking_order
    order("points DESC, name ASC")
  end

  def self.claim_account(from, claim_code, options={})
    channel = options[:channel] || :sms

    claimer_class = case channel
    when :sms
      AccountClaimer::SMSClaimer
    when :email
      AccountClaimer::EmailClaimer
    end

    claimer_class.new(from, claim_code, options).claim
  end

  def self.with_phone_number
    where("phone_number IS NOT NULL AND phone_number != ''")
  end

  def invite(referrer = nil, options ={})
    Mailer.delay.invitation(self, referrer, options)
    update_attribute(:invited, true)
  end

  def mark_as_claimed(number, channel = :web)
    update_attribute(:phone_number, PhoneNumber.normalize(number)) if number.present?
    update_attribute(:accepted_invitation_at, Time.now)
    record_claim_in_mixpanel(channel)
  end

  def finish_claim(reply_mode = :string)
    add_joining_to_activity_stream
    schedule_followup_welcome_message

    welcome_message = demo.welcome_message(self)

    case reply_mode
    when :send
      OutgoingMessage.send_message(self, welcome_message)
    when :string
      welcome_message
    end
  end

  def join_game(number, reply_mode=:string)
    mark_as_claimed(number)
    finish_claim(reply_mode)
  end

  def record_claim_in_mixpanel(channel)
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event("claimed account", {:channel => channel}.merge(self.data_for_mixpanel))
  end

  def update_points(new_points, channel=nil)
    old_points = self.points
    increment!(:points, new_points)
    update_recent_average_points(new_points)
    Level.check_for_level_up(old_points, self, channel)
    check_for_victory(channel)
  end

  def update_recent_average_points(new_points)
    point_gain_factor = (recent_average_history_depth + 1).to_f / (1..(recent_average_history_depth + 1)).sum.to_f
    actual_point_gain = (new_points * point_gain_factor).ceil
    increment!(:recent_average_points, actual_point_gain)
  end

  def password_optional?
    true
  end

  def set_invitation_code
    self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{email}--")
  end

  def find_same_slug(possible_slug)
    User.first(:conditions => ["slug = ? OR sms_slug = ?", possible_slug, possible_slug],
               :order      => "created_at desc")
  end


  def set_slugs_based_on_name
    cleaned = name.remove_mid_word_characters.
                remove_non_words.
                downcase.
                strip
    possible_slug = cleaned
    User.transaction do
      same_name = find_same_slug(possible_slug)

      counter = same_name && same_name.slug.first_digit

      while same_name
        counter += rand(20)
        possible_slug = cleaned + counter.to_s
        same_name = find_same_slug(possible_slug)
      end

      self.slug = possible_slug
      self.sms_slug = self.slug
    end
  end



  def generate_simple_claim_code!
    update_attributes(:claim_code => claim_code_prefix)
  end

  def generate_unique_claim_code!
    potential_claim_code = nil

    User.transaction do
      suffix = rand(100)

      begin
        suffix += rand(50)
        potential_claim_code = claim_code_prefix + suffix.to_s
      end while User.find_by_claim_code(potential_claim_code)

      self.update_attributes(:claim_code => potential_claim_code)
    end

    potential_claim_code
  end

  def point_fraction
    points = self.points_towards_next_threshold
    point_denominator = self.point_threshold_spread
    "#{points}/#{point_denominator}"
  end

  def point_summary
    if self.point_threshold_spread > 0
      "points #{self.point_fraction}"
    else
      "points #{self.points}"
    end
  end

  def level_summary
    "level #{self.top_level_index}"
  end

  def point_and_ranking_summary(prefix = [])
    result_parts = prefix.clone
    result_parts << self.point_summary
    result_parts << self.level_summary

    ' ' + result_parts.join(', ').capitalize + '.'
  end

  def claim_code_prefix
    self.class.claim_code_prefix(self)
  end

  # This is meant to be called by a cron job just after midnight, to
  # recalculate this user's moving average score. Note that this does _not_
  # update the user's ranking, since it's expected that this will be called on
  # a whole batch of users at once, and it'll be more efficient to recalculate
  # all rankings at once afterwards.

  def recalculate_moving_average!
    acts_in_horizon = find_acts_in_horizon
    oldest_act_in_horizon = acts_in_horizon.first

    self.recent_average_history_depth = if oldest_act_in_horizon
                             # Date#- returns not an integer, but a Rational,
                             # for doubtless the best of reasons.
                             (Date.today - oldest_act_in_horizon.created_at.to_date).numerator
                           else
                             0
                           end

    self.recent_average_points = (recent_average_point_numerator(acts_in_horizon) / recent_average_point_denominator).ceil

    # Remember we're deliberately skipping callbacks here because we
    # anticipate updating rankings all in a batch.
    @batch_updating_recent_averages = true
    self.save
    @batch_updating_recent_averages = false
  end

  def recent_average_point_numerator(acts_in_horizon)
    grouped_acts = acts_in_horizon.group_by{|act| act.created_at.to_date}

    point_numerator = 0
    grouped_acts.each do |date_of_act, acts_on_date|
      point_numerator += date_weight(date_of_act) * acts_on_date.map(&:points).compact.sum
    end
    point_numerator.to_f
  end

  def recent_average_point_denominator
    (1..self.recent_average_history_depth + 1).sum
  end

  def find_acts_in_horizon
    horizon = (Date.today - MAX_RECENT_AVERAGE_HISTORY_DEPTH.days).midnight
    acts_in_horizon = acts.where('created_at >= ? AND demo_id = ?', horizon, self.demo_id).order(:created_at)
  end

  def date_weight(date_of_act)
    self.recent_average_history_depth - (Date.today - date_of_act).numerator + 1
  end

  def self.claim_code_prefix(user)
    begin
      names = user.name.downcase.split.map(&:remove_non_words)
      first_name = names.first
      last_name = names.last
      [first_name.first, last_name].join('')
    end
  end

  def move_to_new_demo(new_demo_id)
    old_demo = self.demo
    new_demo = Demo.find(new_demo_id)

    self.demo = new_demo
    self.won_at = self.wins.where(:demo_id => new_demo_id).first.try(:created_at)
    self.points = self.acts.where(:demo_id => new_demo_id).map(&:points).compact.sum
    self.save!
    self.recalculate_moving_average!

    [old_demo, new_demo].each do |demo|
      demo.fix_total_user_rankings!
      demo.fix_recent_average_user_rankings!
    end
  end

  # Returns a list [reply, reply_type] where reply_type should be :success if
  # the action was successful, or an error code if the action failed. As of
  # now the only error code we use is :over_alltime_limit.

  def act_on_rule(rule, rule_value, options={})
    self.last_suggested_items = ''
    self.save!

    if rule.user_hit_limit?(self)
      return ["Sorry, you've already done that action.", :over_alltime_limit]
    else
      credit_referring_user(options[:referring_user], rule, rule_value)
      return [Act.record_act(self, rule, options), :success]
    end
  end

  def open_survey
    # Note: this could be refactored to user Survey.open
    # But It wasn't working for me. Maybe you're smarter than I?
    self.demo.surveys.where('? BETWEEN open_at AND close_at', Time.now).first
  end

  def befriend(other, mixpanel_properties={})
    return nil unless self.demo.game_open?
    friendship = nil
    Friendship.transaction do
      return nil if self.friendships.where(:friend_id => other.id).present?
      friendship = self.friendships.create(:friend_id => other.id, :state => 'initiated')
      reciprocal_friendship = other.friendships.create(:friend_id => self.id, :state => 'pending')
      reciprocal_friendship.update_attribute(:request_index, friendship.request_index)
    end

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event('fanned', self.data_for_mixpanel.merge(mixpanel_properties))

    friendship
  end
  
  def accept_friendship_from(other)
    Friendship.where(:user_id => other.id, :friend_id => self.id).first.accept
  end

  def follow_requested_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      :default => "OK, you'll be friends with %{followed_user_name}, pending %{her_his} acceptance.",
      :followed_user_name => self.name,
      :her_his => self.her_his
    )
  end
  

  def follow_removed_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      :default => "OK, you're no longer friends with %{followed_user_name}.",
      :followed_user_name => self.name
    )
  end
  
  def follow_accepted_message
    message = "#{name} has approved your friendship request."

    points_from_demo = self.demo.points_for_connecting
    return message if points_from_demo.nil?

    if points_from_demo > 0 && self.connection_bounty > 0
      message += I18n.t(
        "activerecord.models.follow_message_with_split_bonus",
        :default => " You've collected %{points_from_demo} bonus points for the connection, plus another %{points_from_user} bonus points.",
        :points_from_demo => points_from_demo,
        :points_from_user => self.connection_bounty
      )
    elsif (bonus_points = [points_from_demo, self.connection_bounty].max) > 0
      message += I18n.t(
        "activerecord.models.follow_message_with_single_bonus",
        :default => " You've collected %{bonus_points} bonus points for the connection.",
        :bonus_points => bonus_points
      )
    end

    message
  end

  def points_denominator
    next_point_goal
  end

  def last_point_goal
    last_achieved_threshold || 0
  end

  def next_point_goal
    next_unachieved_threshold || greatest_achievable_threshold
  end

  def displayable_task_suggestions
    self.task_suggestions.displayable.includes(:task)
  end

  def satisfies_all_prerequisites(task)
    task.prerequisite_tasks.all?{|prerequisite_task| self.task_suggestions.for_task(prerequisite_task).satisfied.present?}
  end

  def satisfy_suggestions_by_survey(survey_or_survey_id, channel)
    satisfiable_suggestions = self.task_suggestions.satisfiable_by_survey(survey_or_survey_id).readonly(false)
    satisfiable_suggestions.each{|satisfiable_suggestion| satisfiable_suggestion.satisfy!(channel)}
  end

  def satisfy_suggestions_by_rule(rule_or_rule_id, channel, referring_user_id = nil)
    return unless rule_or_rule_id
    satisfiable_suggestions = self.task_suggestions.satisfiable_by_rule(rule_or_rule_id).readonly(false)

    unless referring_user_id
      satisfiable_suggestions = satisfiable_suggestions.without_mandatory_referrer
    end

    satisfiable_suggestions.each{|satisfiable_suggestion| satisfiable_suggestion.satisfy!(channel)}
  end

  def height_feet
    return nil unless height
    height / 12
  end

  def height_inches
    return nil unless height
    height % 12
  end

  def points_towards_next_threshold
    self.points - last_point_goal
  end

  def percent_towards_next_threshold
    return 100.0 unless next_point_goal

    numerator = self.points - last_point_goal
    return 0.0 if numerator == 0
  
    denominator = point_threshold_spread
    return 100.0 if denominator == 0

    percent = (numerator.to_f / denominator.to_f * 100).round(2)

    percent > 100 ? 100.0 : percent
  end

  def point_threshold_spread
    _next_point_goal = next_point_goal
    _last_point_goal = last_point_goal
    return 0 if _next_point_goal.nil? || _last_point_goal.nil?
    _next_point_goal - _last_point_goal
  end

  def email_with_name
    "#{name} <#{email}>"
  end
  
  def mute_for_now
    self.update_attributes(:last_muted_at => Time.now)
  end

  def invitation_sent_text
    "An invitation has been sent to #{self.email}."
  end

  def claimed?
    self.accepted_invitation_at.present?
  end

  def unclaimed?
    !(self.claimed?)
  end

  def add_flash_for_next_request!(body, flash_status)
    _flash_status = flash_status.to_sym
    new_flashes = self.flashes_for_next_request || {}
    new_flashes[flash_status] ||= []
    new_flashes[flash_status] << body

    self.update_attributes(:flashes_for_next_request => new_flashes)

    new_flashes
  end

  def tutorial_active?
    tutorial = self.tutorial
    if tutorial
      return false if tutorial.ended_at
      return true
    end
    return false
  end
  
  def create_tutorial_if_none_yet
    if self.tutorial.nil?
      tut = Tutorial.create(:user_id => self.id)
    else
      tut = self.tutorial
    end
  end

  def create_active_tutorial_at_slide_one
    tut = create_tutorial_if_none_yet
    tut.current_step = 1
    tut.created_at = Time.now
    tut.ended_at = nil
    tut.save
  end

  def profile_page_friends_list
    self.accepted_friends_same_demo.sort_by {|ff| ff.name.downcase}
  end
  
  def scoreboard_friends_list_by_points
    (self.accepted_friends_same_demo + [self]).sort_by {|ff| ff.points}.reverse
  end
  
  def scoreboard_friends_list_by_name
    (self.accepted_friends_same_demo + [self]).sort_by {|ff| ff.name.downcase}
  end
  
  def self.name_starts_with(start)
    where("name ILIKE ?", start.like_escape + "%")
  end

  def self.name_starts_with_non_alpha
    where("name !~* '^[[:alpha:]]'")
  end

  def self.send_invitation_if_email(phone, text, options={})
    return nil unless phone =~ /^(\+1\d{10})$/

    _text = text.downcase.strip.gsub(" ", "")

    if (existing_user = User.where(:email => _text).first)
      if existing_user.claimed?
        return "It looks like you've already joined the game. If you've forgotten your password, you can have it reset online, or contact support@hengage.com for help." 
      else
        # If there's someone with this email who hasn't accepted an invitation yet
        # treat this as a request to re-send their invitation.
      
        existing_user.invite(nil, options)
        return existing_user.invitation_sent_text
      end
    end

  end

  def self.reset_all_mt_texts_today_counts!
    User.update_all :mt_texts_today => 0
  end

  def self.authenticate(email_or_sms_slug, password)
    user = User.where('sms_slug = ? OR email = ?', email_or_sms_slug.to_s.downcase, email_or_sms_slug.to_s.downcase).first
    user && user.authenticated?(password) ? user : nil
  end

  def self.referrer_hash(referrer)
    if referrer
      {:referrer_id => referrer.id}
    else
      {:referrer_id => nil}
    end
  end
 
  def manually_set_confirmation_token
    update_attribute(:confirmation_token, SecureRandom.hex(16))
  end

  def ping(event, properties)
    data = data_for_mixpanel.merge(properties) 
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track_event(event, data)
  end

  def ping_page(page)
    event = 'viewed page'
    properties = {page_name: page}
    ping(event, properties)
  end

  def self.wants_email
    where(:notification_method => %w(email both))
  end

  def self.wants_sms
    where(:notification_method => %w(sms both))
  end

  protected

  def name_required
    # While trying to accept the invitation and at any point after the invitation
    # is accepted, a user must have both a name and an sms slug. Until then, anything goes.
    self.accepted_invitation_at || self.trying_to_accept
  end

  def slug_required
    # slug required if there is a name
    self.name.present? || self.trying_to_accept
  end

  def downcase_email
    self.email = email.to_s.downcase
  end

  def destroy_friendships_where_secondary
    Friendship.destroy_all(:friend_id => self.id)
  end

  def fix_demo_rankings
    self.demo.fix_total_user_rankings!
    self.demo.fix_recent_average_user_rankings!
  end

  def last_achieved_threshold
    threshold_from_last_level = self.last_level.try(:threshold)

    [achieved_victory_threshold_from_demo, threshold_from_last_level].compact.max
  end

  def next_unachieved_threshold
    threshold_from_next_level = self.next_level.try(:threshold)

    [unachieved_victory_threshold_from_demo, threshold_from_next_level].compact.min
  end

  def greatest_achievable_threshold
    threshold_from_demo = self.demo.victory_threshold
    threshold_from_highest_level = self.highest_possible_level.try(:threshold)

    if threshold_from_demo && self.points > threshold_from_demo
      [threshold_from_highest_level, threshold_from_demo].compact.max
    else
      threshold_from_demo || threshold_from_highest_level
    end
  end
  
  def last_level
    demo.levels.where("threshold <= ?", self.points).order("threshold DESC").limit(1).first
  end

  def next_level
    demo.levels.where("threshold > ?", self.points).order("threshold ASC").limit(1).first
  end

  def highest_possible_level
    demo.levels.order("threshold DESC").limit(1).first
  end

  def unachieved_victory_threshold_from_demo
    threshold_from_demo = self.demo.victory_threshold
    if threshold_from_demo && threshold_from_demo > self.points
      threshold_from_demo
    else
      nil
    end
  end

  def achieved_victory_threshold_from_demo
    threshold_from_demo = self.demo.victory_threshold
    if threshold_from_demo && threshold_from_demo <= self.points
      threshold_from_demo
    else
      nil
    end
  end

  def normalized_new_phone_number_unique
    normalize_unique(:new_phone_number)
  end

  def normalized_phone_number_unique
    normalize_unique(:phone_number)
  end

  def normalize_unique(input)
    return if self[input].blank?
    normalized_number = PhoneNumber.normalize(self[input])

    where_conditions = if self.new_record?
                         ["phone_number = ?", normalized_number]
                       else
                         ["phone_number = ? AND id != ?", normalized_number, self.id]
                       end
    if self.class.where(where_conditions).limit(1).present?
      self.errors.add(input, "Sorry, but that phone number has already been taken. Need help? Contact support@hengage.com")
    end
  end

  def downcase_sms_slug
    return unless self.sms_slug
    self.sms_slug.downcase!
  end

  def mute_notice_threshold
    self.demo.mute_notice_threshold || DEFAULT_MUTE_NOTICE_THRESHOLD
  end

  def update_associated_act_privacy_levels
    # See Act for an explanation of why we denormalize privacy_level onto it.
    Act.update_all({:privacy_level => self.privacy_level}, {:user_id => self.id}) if self.changed.include?('privacy_level')
  end

  def self.claimable_by_first_name_and_claim_code(claim_string)
    normalized_claim_string = claim_string.downcase.gsub(/\s+/, ' ').strip
    first_name, claim_code = normalized_claim_string.split
    return nil unless (first_name && claim_code)
    User.where(["name ILIKE ? AND claim_code = ?", first_name.like_escape + '%', claim_code]).first
  end
  
  def self.claimed
    where("accepted_invitation_at IS NOT NULL")
  end

  def self.unclaimed
    where(:accepted_invitation_at => nil)
  end

  def self.for_short_ranking_page(ranking_offset)
    claimed.
    in_canonical_ranking_order.
    offset(ranking_offset).
    map{|user| "#{user.name} (#{user.points})"}
  end

  private

  def self.add_joining_to_activity_stream(user)
    Act.create!(
      :user            => user,
      :text            => 'joined the game',
      :inherent_points => user.demo.seed_points
    )
  end

  def add_joining_to_activity_stream
    self.class.add_joining_to_activity_stream(self)
  end

  def check_for_victory(channel=nil)
    return unless (victory_threshold = self.demo.victory_threshold)

    if !self.won_at && self.points >= victory_threshold
      self.won_at = Time.now
      self.save!

      self.wins.create!(:demo_id => self.demo_id, :created_at => self.won_at)

      send_victory_notices(channel)
    end
  end

  def send_victory_notices(channel = nil)
    OutgoingMessage.send_side_message(self, self.demo.victory_sms(self), :channel => channel)

    OutgoingMessage.send_message(
      self.demo.victory_verification_sms_number,
      "#{self.name} (#{self.email}) won with #{self.points} points"
    ) if self.demo.victory_verification_sms_number

    Mailer.delay.victory(self) if self.demo.victory_verification_email
  end


  def credit_referring_user(referring_user, rule, rule_value)
    return unless referring_user

    act_text = I18n.interpolate(
      "told %{name} about a command",
      :name       => self.name,
      :rule_value => rule_value.value
    )

    points_earned_by_referring = (rule.referral_points) || (rule.points ? rule.points / 2 : 0)
    points_phrase = points_earned_by_referring == 1 ? "1 point" : "#{points_earned_by_referring} points"

    Act.create!(
      :user => referring_user,
      :text => act_text,
      :inherent_points => points_earned_by_referring
    )

    sms_text = I18n.interpolate(
      %{+%{points}, %{name} tagged you in the "%{rule_value}" command.%{point_and_ranking_summary}},
      :points                    => points_phrase,
      :name                      => self.name,
      :rule_value                => rule_value.value,
      :point_and_ranking_summary => referring_user.point_and_ranking_summary
    )

    OutgoingMessage.send_message(referring_user, sms_text)
  end

  def update_demo_ranked_user_count
    return unless (changes['phone_number'] || changes['demo_id'])

    old_number, new_number = changes['phone_number']
    old_demo_id, new_demo_id = changes['demo_id']

    if (!old_number.nil? && !new_number.nil?)
      update_demo_ranked_user_count_based_on_phone_number(old_number, new_number)
    else
      update_demo_ranked_user_count_based_on_demo_id(old_demo_id, new_demo_id)
    end
  end

  def update_demo_ranked_user_count_based_on_phone_number(old_number, new_number)
    case [old_number.present?, new_number.present?]
    when [false, true]
      Demo.increment_counter(:ranked_user_count, demo_id)
    when [true, false]
      Demo.decrement_counter(:ranked_user_count, demo_id)
    end
  end

  def update_demo_ranked_user_count_based_on_demo_id(old_demo_id, new_demo_id)
    return unless phone_number.present?

    Demo.increment_counter(:ranked_user_count, new_demo_id)
    Demo.decrement_counter(:ranked_user_count, old_demo_id)
  end

  def decrement_demo_ranked_user_count
    return unless phone_number.present?
    Demo.decrement_counter(:ranked_user_count, demo_id)
  end

  def suggest_first_level_tasks
    self.demo.tasks.first_level.after_start_time_and_before_end_time.each do |first_level_task|
      first_level_task.suggest_to_user(self)
    end
  end

  def trigger_demographic_tasks
    if all_demographics_present? && not_all_demographics_previously_present?
      self.task_suggestions.satisfiable_by_demographics.readonly(false).each(&:satisfy!)
    end
  end

  def all_demographics_present?
    DEMOGRAPHIC_FIELD_NAMES.all?{|field_name| self[field_name].present?}
  end

  def not_all_demographics_previously_present?
    DEMOGRAPHIC_FIELD_NAMES.any? do |demographic_field_name|
      !changed.include?(demographic_field_name)
    end
  end
  
  def self.get_users_where_like(text, demo, attribute, user_to_exempt = nil)
    users = User.where("LOWER(#{attribute}) like ?", "%" + text + "%").where(:demo_id => demo.id )
    users = users.where('users.id != ?', user_to_exempt.id) if user_to_exempt
    users
  end
  
  def self.get_claimed_users_where_like(text, demo, attribute)
    get_users_where_like(text, demo, attribute).claimed
  end
  
  def self.passwords_dont_match_error_message
    "Sorry, your passwords don't match"
  end
  
  def self.next_id
    self.last.nil? ? 1 : self.last.id + 1
  end
end
