require 'digest/sha1'

class User < ActiveRecord::Base
  # Maximum number of days back we will consider acts in the moving average
  # (counting today as day 0)
  MAX_RECENT_AVERAGE_HISTORY_DEPTH = 6

  DEFAULT_RANKING_CUTOFF = 15

  DEMOGRAPHIC_FIELD_NAMES = %w(gender date_of_birth).freeze

  PRIVACY_LEVELS = %w(everybody connected nobody).freeze

  DEFAULT_MUTE_NOTICE_THRESHOLD = 10

  include Clearance::User
  include User::Ranking

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
  has_many   :task_suggestions
  has_and_belongs_to_many :bonus_thresholds
  has_and_belongs_to_many :levels

  validate :normalized_phone_number_unique, :normalized_new_phone_number_unique

  validates_uniqueness_of :slug, :if => :slug_required
  validates_uniqueness_of :sms_slug, :message => "Sorry, that username is already taken.", :if => :slug_required

  validates_presence_of :name, :if => :name_required, :message => "Please enter your first and last name"
  validates_presence_of :sms_slug, :message => "Please choose a username", :if => :slug_required
  validates_presence_of :slug, :if => :slug_required
  
  validates_presence_of :privacy_level
  validates_inclusion_of :privacy_level, :in => PRIVACY_LEVELS

  validates_format_of :slug, :with => /^[0-9a-z]+$/, :if => :slug_required
  validates_format_of :sms_slug, :with => /^[0-9a-z]+$/, :if => :slug_required,
                      :message => "Sorry, the username must consist of letters or digits only."

  validates_presence_of :demo_id
  validates_numericality_of :height, :allow_blank => true, :message => "Please use a numeric value for your height, and express it in inches"
  validates_numericality_of :weight, :allow_blank => true, :message => "Please use a numeric value for your weight, and express it in pounds"

  validates_acceptance_of :terms_and_conditions, :if => :trying_to_accept, :message => "You must accept the terms and conditions" 

  validates_length_of :password, :minimum => 6, :allow_blank => true, :message => 'must have at least 6 characters'

  has_attached_file :avatar,
    :styles => {:thumb => "48x48#"},
    :default_style => :thumb,
    #:processors => [:png],
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_protocol => 'https',
    :path => "/avatars/:id/:style/:filename",
    :bucket => S3_AVATAR_BUCKET

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
    set_alltime_rankings
    set_recent_average_rankings
  end

  before_update do
    schedule_update_demo_alltime_rankings if changed.include?('points')
    schedule_update_demo_recent_average_rankings if (!batch_updating_recent_averages && changed.include?('recent_average_points'))
    trigger_demographic_tasks
  end

  before_save do
    downcase_email
    update_demo_ranked_user_count
  end

  after_create do
    suggest_first_level_tasks
  end

  after_destroy do
    destroy_friendships_where_secondary
    fix_demo_rankings
    decrement_demo_ranked_user_count
  end

  attr_reader :batch_updating_recent_averages

  attr_accessor :trying_to_accept
  attr_protected :is_site_admin, :invitation_method

  has_alphabetical_column :name

  def update_password_with_blank_forbidden(password, password_confirmation)
    # See comment in user_spec for #update_password.
    unless password.present?
      self.errors.add :password, "Please choose a password"
      return false
    end

    update_password_without_blank_forbidden(password, password_confirmation)
  end

  alias_method_chain :update_password, :blank_forbidden

  def followers
    # You'd think you could do this with an association, and if you can figure
    # out how to get that to work, please, be my guest.

    self.class.joins("INNER JOIN friendships on users.id = friendships.user_id").where('friendships.friend_id = ?', self.id)
  end

  def pending_followers
    followers.where('friendships.state' => 'pending')
  end

  def accepted_followers
    followers.where('friendships.state' => 'accepted')
  end

  def pending_friends
    friends.where('friendships.state' => 'pending')
  end

  def accepted_friends
    friends.where('friendships.state' => 'accepted')
  end

  def pending_friendships
    friendships.where(:state => 'pending')
  end

  def accepted_friendships
    friendships.where(:state => 'accepted')
  end

  # See comment by Demo#acts_with_current_demo_checked for an explanation of
  # why we do this.

  %w(friends pending_friends accepted_friends followers pending_followers accepted_followers).each do |base_method_name|
    class_eval <<-END_DEF
      def #{base_method_name}_with_in_current_demo
        #{base_method_name}_without_in_current_demo.where(:demo_id => self.demo_id)
      end

      alias_method_chain :#{base_method_name}, :in_current_demo
    END_DEF

  end

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
    SMS.send_message self.new_phone_number, "Your code to verify this phone with H Engage is #{self.new_phone_validation}.", nil, :from_demo => self.demo
  end

  def validate_new_phone(entered_validation_code)
    entered_validation_code == self.new_phone_validation
  end

  def schedule_followup_welcome_message
    return if (message = self.demo.followup_welcome_message).blank?

    SMS.send_message(self, message, Time.now + demo.followup_welcome_message_delay.minutes)
  end

  def self_inviting_domain
    self.class.self_inviting_domain(self.email)
  end

  def bump_mt_texts_sent_today
    increment!(:mt_texts_today)
    if self.mt_texts_today == self.mute_notice_threshold && !(self.suppress_mute_notice)
      SMS.send_message(self, "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text GOT IT.")
    end
  end

  def self.in_canonical_ranking_order
    order("points DESC, name ASC")
  end

  def self.with_ranking_cutoff(cutoff = DEFAULT_RANKING_CUTOFF)
    where("ranking <= #{cutoff}")
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

  def invite(referrer = nil)
    Mailer.delay.invitation(self, referrer)
    update_attribute(:invited, true)
  end

  def mark_as_claimed(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number)) if number.present?
    update_attribute(:accepted_invitation_at, Time.now)
  end

  def finish_claim(reply_mode = :string)
    add_joining_to_activity_stream
    schedule_followup_welcome_message

    welcome_message = demo.welcome_message(self)

    case reply_mode
    when :send
      SMS.send_message(self, welcome_message)
    when :string
      welcome_message
    end
  end

  def join_game(number, reply_mode=:string)
    mark_as_claimed(number)
    finish_claim(reply_mode)
  end

  def update_points(new_points)
    old_points = self.points
    increment!(:points, new_points)
    update_recent_average_points(new_points)
    BonusThreshold.consider_awarding_points_for_crossed_bonus_thresholds(old_points, self)
    Level.check_for_level_up(old_points, self)
    check_for_victory
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

  def following?(other)
    friends.include?(other)
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

  def point_and_ranking_summary(_points_denominator, prefix = [])
    result_parts = prefix.clone

    if _points_denominator
      result_parts << "points #{self.points}/#{_points_denominator}"
    end

    result_parts << "rank #{self.ranking}/#{self.demo.ranked_user_count}"

    result_parts.join(', ').capitalize + '.'
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

  def act_on_rule(rule, rule_value, referring_user=nil)
    self.last_suggested_items = ''
    self.save!

    if rule.user_hit_limit?(self)
      return ["Sorry, you've already done that action.", :over_alltime_limit]
    else
      credit_referring_user(referring_user, rule, rule_value)
      return [Act.record_act(self, rule, referring_user), :success]
    end
  end

  def open_survey
    self.demo.surveys.open.first
  end

  def befriend(other)
    return nil unless self.demo.game_open?

    Friendship.transaction do
      return nil if self.friendships.where(:friend_id => other.id).present?
      self.friendships.create(:friend_id => other.id)
    end
  end

  def follow_requested_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      :default => "OK, you'll be a fan of %{followed_user_name}, pending their acceptance.",
      :followed_user_name => self.name
    )
  end

  def follow_accepted_message
    message = "#{name} has approved your request to be a fan."

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
    self.task_suggestions.displayable.includes(:suggested_task)
  end

  def satisfies_all_prerequisites(suggested_task)
    suggested_task.prerequisite_tasks.all?{|prerequisite_task| self.task_suggestions.for_task(prerequisite_task).satisfied.present?}
  end

  def satisfy_suggestions_by_survey(survey_or_survey_id)
    satisfiable_suggestions = self.task_suggestions.satisfiable_by_survey(survey_or_survey_id)
    satisfiable_suggestions.each(&:satisfy!)
  end

  def satisfy_suggestions_by_rule(rule_or_rule_id, referring_user_id = nil)
    return unless rule_or_rule_id
    satisfiable_suggestions = self.task_suggestions.satisfiable_by_rule(rule_or_rule_id)

    unless referring_user_id
      satisfiable_suggestions = satisfiable_suggestions.without_mandatory_referrer
    end

    satisfiable_suggestions.each(&:satisfy!)
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

  def self.next_dummy_number
   last_assigned = self.where("phone_number LIKE '+1999%'").order("phone_number DESC").limit(1).first

    if last_assigned
      last_number_int = last_assigned.phone_number.to_i
      "+" + (last_number_int + 1).to_s
    else
      "+19995550000"
    end
  end

  def self.name_starts_with(start)
    where("name ILIKE ?", start.like_escape + "%")
  end

  def self.name_starts_with_non_alpha
    where("name !~* '^[[:alpha:]]'")
  end

  def self.send_invitation_if_email(phone, text, options={})
    return nil unless phone =~ /^(\+1\d{10})$/

    if (existing_user = User.where(:email => text).first)
      if existing_user.claimed?
        return "It looks like you've already joined the game. If you've forgotten your password, you can have it reset online, or contact support@hengage.com for help." 
      else
        # If there's someone with this email who hasn't accepted an invitation yet
        # treat this as a request to re-send their invitation.
      
        existing_user.invite
        return existing_user.invitation_sent_text
      end
    end

    new_user, create_details = self.new_self_inviting_user(text)
    return create_details[:error] unless new_user

    new_user.invitation_method = 'sms'
    new_user.phone_number = phone

    if new_user.save
      new_user.invite
      new_user.invitation_sent_text
    else
      nil
    end
  end

  def self.self_inviting_domain(email)
    domain = email.email_domain
    SelfInvitingDomain.where(:domain => domain).first
  end

  def self.reset_all_mt_texts_today_counts!
    User.update_all :mt_texts_today => 0
  end

  def self.new_self_inviting_user(email)

    domain_string = email.email_domain
    return [nil, {}] unless domain_string

    domain_object = SelfInvitingDomain.where(:domain => domain_string).first
    return [nil, {:error => "Your domain is not valid"}] unless domain_object

    User.new(:email => email.strip, :demo_id => domain_object.demo_id)
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

  def self.claimable_by_email_address(claim_string)
    normalized_email = claim_string.gsub(/\s+/, '')
    User.find(:first, :conditions => ["email ILIKE ? AND claim_code != ''", normalized_email.like_escape])
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
    map{|user| "#{user.ranking}. #{user.name} (#{user.points})"}
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

  def check_for_victory
    return unless (victory_threshold = self.demo.victory_threshold)

    if !self.won_at && self.points >= victory_threshold
      self.won_at = Time.now
      self.save!

      self.wins.create!(:demo_id => self.demo_id, :created_at => self.won_at)

      send_victory_notices
    end
  end

  def send_victory_notices
    SMS.send_side_message(self, self.demo.victory_sms(self))

    SMS.send_message(
      self.demo.victory_verification_sms_number,
      "#{self.name} (#{self.email}) won with #{self.points} points"
    ) if self.demo.victory_verification_sms_number

    Mailer.victory(self).deliver if self.demo.victory_verification_email
  end


  def credit_referring_user(referring_user, rule, rule_value)
    return unless referring_user

    act_text = I18n.interpolate(
      "told %{name} about a command",
      :name       => self.name,
      :rule_value => rule_value.value
    )

    points_denominator_before_referring_act = referring_user.points_denominator
    points_earned_by_referring = (rule.referral_points) || (rule.points / 2)
    points_phrase = points_earned_by_referring == 1 ? "1 point" : "#{points_earned_by_referring} points"

    Act.create!(
      :user => referring_user,
      :text => act_text,
      :inherent_points => points_earned_by_referring
    )

    sms_text = I18n.interpolate(
      %{+%{points}, %{name} tagged you in the "%{rule_value}" command. %{point_and_ranking_summary}},
      :points                    => points_phrase,
      :name                      => self.name,
      :rule_value                => rule_value.value,
      :point_and_ranking_summary => referring_user.point_and_ranking_summary(points_denominator_before_referring_act)
    )
    SMS.send_message(referring_user, sms_text)
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
    self.demo.suggested_tasks.first_level.after_start_time.each do |first_level_task|
      first_level_task.suggest_to_user(self)
    end
  end

  def trigger_demographic_tasks
    if all_demographics_present? && not_all_demographics_previously_present?
      self.task_suggestions.satisfiable_by_demographics.each(&:satisfy!)
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
end
