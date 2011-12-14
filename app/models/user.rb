require 'digest/sha1'

class User < ActiveRecord::Base
  # Maximum number of days back we will consider acts in the moving average
  # (counting today as day 0)
  MAX_RECENT_AVERAGE_HISTORY_DEPTH = 6

  DEFAULT_RANKING_CUTOFF = 15

  include Clearance::User

  belongs_to :demo
  belongs_to :game_referrer, :class_name => "User"
  has_many   :acts, :dependent => :destroy
  has_many   :friendships, :dependent => :destroy
  has_many   :friends, :through => :friendships
  has_many   :survey_answers
  has_many   :wins, :dependent => :destroy
  has_many   :goal_completions
  has_many   :completed_goals, :through => :goal_completions, :source => :goal
  has_many   :timed_bonuses, :class_name => "TimedBonus"
  has_and_belongs_to_many :bonus_thresholds
  has_and_belongs_to_many :levels

  validates_uniqueness_of :phone_number, :allow_blank => true
  validates_uniqueness_of :slug
  validates_uniqueness_of :sms_slug, :message => "Sorry, that user ID is already taken."

  validates_presence_of :name
  validates_presence_of :sms_slug, :message => "Sorry, you can't choose a blank user ID."

  has_attached_file :avatar, 
    :styles => {:thumb => "48x48#"}, 
    :default_style => :thumb,
    #:processors => [:png],
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_protocol => 'https',
    :path => "/avatars/:id/:style/:filename",
    :bucket => S3_AVATAR_BUCKET

  before_validation(:on => :create) do
    set_slugs
  end

  before_create do
    set_invitation_code
    set_alltime_rankings
    set_recent_average_rankings
  end

  before_update do
    schedule_update_demo_alltime_rankings if changed.include?('points')
    schedule_update_demo_recent_average_rankings if (!batch_updating_recent_averages && changed.include?('recent_average_points'))
  end

  before_save do
    downcase_email
    update_demo_ranked_user_count
  end

  after_destroy do
    destroy_friendships_where_secondary
    fix_demo_rankings
    decrement_demo_ranked_user_count
  end

  attr_reader :batch_updating_recent_averages

  attr_protected :is_site_admin

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

    Mailer.delay.support_request(self.name, self.email, self.phone_number, self.demo.company_name, latest_act_descriptions)
  end

  def first_eligible_rule_value(value)
    matching_rule_values = RuleValue.visible_from_demo(self).where(:value => value)
    matching_rule_values.select{|rule_value| rule_value.not_forbidden?}.first || matching_rule_values.first  
  end

  def self.alphabetical
    order("name asc")
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

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def mark_as_claimed(number)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
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

  def set_slugs
    return nil unless name.present?

    cleaned = name.remove_mid_word_characters.
                replace_non_words_with_spaces.
                strip.
                replace_spaces_with_hyphens
    possible_slug = cleaned
    possible_sms_slug = self.claim_code_prefix

    User.transaction do
      same_name = find_same_slug(possible_slug, possible_sms_slug)
      counter = same_name && same_name.slug.first_digit

      while same_name
        counter += rand(20)
        possible_slug = "#{cleaned}-#{counter}"
        possible_sms_slug = self.claim_code_prefix + counter.to_s
        same_name = find_same_slug(possible_slug, possible_sms_slug)
      end

      self.slug = possible_slug
      self.sms_slug = possible_sms_slug
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

  def set_ranking(points_column, ranking_column)
    User.transaction do
      new_point_value = self[points_column]

      self[ranking_column] = self.demo.users.where("#{points_column} > ?", new_point_value).count + 1
      old_point_value = self.changed_attributes[points_column]

      # Remember, we haven't saved the new point value yet, so if self isn't a
      # new record (hence already has a database ID), we need to specifically
      # exempt it from this update.

      if self.id
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ? AND id != ?", new_point_value, old_point_value, self.id]
      else
        where_conditions = ["#{points_column} < ? AND #{points_column} >= ?", new_point_value, old_point_value]
      end

      # This mitigates, but doesn't totally prevent, deadlocks. Until I think
      # of a better algorithm, or we can get Postgres to lock the fucking rows
      # in a consistent fucking order, we're done here.
      user_ids_to_update = self.demo.users.where(where_conditions).order(:id).select("id").lock("FOR UPDATE").map(&:id)
      User.update_all("#{ranking_column} = #{ranking_column} + 1", :id => user_ids_to_update)
    end
  end

  def set_alltime_rankings
    set_ranking('points', 'ranking')
  end

  def set_recent_average_rankings
    set_ranking('recent_average_points', 'recent_average_ranking')
  end

  def schedule_update_demo_alltime_rankings
    self.demo.delay.fix_total_user_rankings!
  end

  def schedule_update_demo_recent_average_rankings
    self.demo.delay.fix_recent_average_user_rankings!
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
      date_weight = self.recent_average_history_depth - (Date.today - date_of_act).numerator + 1
      point_numerator += date_weight * acts_on_date.map(&:points).compact.sum
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
    next_unachieved_threshold || greatest_achievable_threshold
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
    where("name NOT SIMILAR TO '^[[:alpha:]]%'")   
  end

  protected

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

  def find_same_slug(possible_slug, possible_sms_slug)
    User.first(:conditions => ["slug = ? OR sms_slug = ?", possible_slug, possible_sms_slug],
               :order      => "created_at desc")
  end

  def credit_referring_user(referring_user, rule, rule_value)
    return unless referring_user

    act_text = I18n.translate(
      'activerecord.models.user.referred_a_command_act', 
      :default    => "told %{name} about a command", 
      :name       => self.name, 
      :rule_value => rule_value.value
    )

    points_denominator_before_referring_act = referring_user.points_denominator

    Act.create!(
      :user => referring_user,
      :text => act_text,
      :inherent_points => (rule.referral_points) || (rule.points / 2)
    )

    sms_text = I18n.translate(
      'activerecord.models.user.thanks_for_referring_sms', 
      :default                   => 'Thanks for referring %{name} to the %{rule_value} command. %{point_and_ranking_summary}', 
      :name                      => self.name, 
      :rule_value                => rule_value.value, 
      :point_and_ranking_summary => referring_user.point_and_ranking_summary(points_denominator_before_referring_act)
    )
    SMS.send_message(referring_user, sms_text)
  end

  def schedule_followup_welcome_message
    return if (message = self.demo.followup_welcome_message).blank?

    SMS.send_message(self, message, Time.now + demo.followup_welcome_message_delay.minutes)
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
end
