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
  has_and_belongs_to_many :bonus_thresholds
  has_and_belongs_to_many :levels

  validates_uniqueness_of :phone_number, :allow_blank => true
  validates_uniqueness_of :slug
  validates_uniqueness_of :sms_slug, :message => "Sorry, that unique ID is already taken."

  validates_presence_of :name
  validates_presence_of :sms_slug, :message => "Sorry, you can't choose a blank unique ID."

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
    set_alltime_rankings if changed.include?('points')
    set_recent_average_rankings if (!batch_updating_recent_averages && changed.include?('recent_average_points'))
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
    rankings_strings = self.demo.users.
                          ranked.
                          in_canonical_ranking_order.
                          offset(_ranking_query_offset).
                          map{|user| "#{user.ranking}. #{user.name} (#{user.points})"}

    if rankings_strings.empty?
      # back to the top
      self.ranking_query_offset = 0
      self.save!
      return I18n.translate('activerecord.models.user.end_of_rankings', :default => "That's everybody! Send RANKINGS to start over from the top.")
    end

    while(rankings_strings.map(&:length).sum > 159 - more_rankings_prompt.length)
      rankings_strings.pop
    end

    rankings_string = rankings_strings.join("\n")
    response = rankings_string + "\n" + more_rankings_prompt

    if options[:reset_offset] || self.ranking_query_offset.nil?
      self.ranking_query_offset = 0
    end
    self.ranking_query_offset += rankings_strings.length
    self.save!

    response
  end

  def send_support_request
    latest_act_descriptions = RawSms.where(:from => self.phone_number).order("created_at DESC").limit(20).map(&:body)

    Mailer.delay.support_request(self.name, self.email, self.phone_number, self.demo.company_name, latest_act_descriptions)
  end

  def first_eligible_rule_value(value)
    matching_rule_values = RuleValue.visible_from_demo(self).where(:value => value)
    matching_rule_values.select{|rule_value| rule_value.not_forbidden?}.first || matching_rule_values.first  
  end

  def self.alphabetical
    order("name asc")
  end

  def self.top(limit=10)
    order("points desc").limit(limit)
  end

  def self.ranked
    where("phone_number IS NOT NULL AND phone_number != ''")
  end

  def self.in_canonical_ranking_order
    order("points DESC, name ASC")
  end

  def self.with_ranking_cutoff(cutoff = DEFAULT_RANKING_CUTOFF)
    where("ranking <= #{cutoff}")
  end

  def self.claim_account(from, claim_code, options={})
    normalized_claim_code = claim_code.gsub(/\W+/, '')
    users = User.find(:all, :conditions => ["claim_code ILIKE ?", normalized_claim_code])

    if users.count > 1
      return "There's more than one person with that code. Please try sending us your first name along with the code (for example: John Smith enters \"john jsmith\")."
    end

    user = users.first || User.claimable_by_email_address(claim_code) || User.claimable_by_first_name_and_claim_code(claim_code)

    return nil unless user

    if (existing_user = User.find_by_phone_number(from))
      return I18n.t(
        'activerecord.models.user.claim_account.already_claimed_sms',
        :default => "You've already claimed ur account, and have %{current_points} pts. If you're trying to credit another user, ask them to check their unique ID with the MYID command.",
        :current_points => existing_user.points
      )
    end

    user.forgot_password!
    Mailer.delay.set_password(user.id)

    user.join_game(from)
  end

  def invite
    Mailer.invitation(self).deliver
    update_attribute(:invited, true)
  end

  def join_game(number, reply_mode = :string)
    update_attribute(:phone_number, PhoneNumber.normalize(number))
    update_attribute(:accepted_invitation_at, Time.now)

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

  def gravatar_url(size)
    Gravatar.new(email).url(size)
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

      self.demo.users.update_all("#{ranking_column} = #{ranking_column} + 1", where_conditions)
    end
  end

  def set_alltime_rankings
    set_ranking('points', 'ranking')
  end

  def set_recent_average_rankings
    set_ranking('recent_average_points', 'recent_average_ranking')
  end

  def point_and_ranking_summary(prefix = [])
    result_parts = prefix.clone
    
    if (victory_threshold = self.demo.victory_threshold)
      result_parts << "points #{self.points}/#{victory_threshold}"
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
    horizon = (Date.today - MAX_RECENT_AVERAGE_HISTORY_DEPTH.days).midnight
    acts_in_horizon = acts.where('created_at >= ? AND demo_id = ?', horizon, self.demo_id).order(:created_at)
    oldest_act_in_horizon = acts_in_horizon.first

    self.recent_average_history_depth = if oldest_act_in_horizon
                             # Date#- returns not an integer, but a Rational, 
                             # for doubtless the best of reasons.
                             (Date.today - oldest_act_in_horizon.created_at.to_date).numerator
                           else
                             0
                           end

    grouped_acts = acts_in_horizon.group_by{|act| act.created_at.to_date}

    point_numerator = 0
    grouped_acts.each do |date_of_act, acts_on_date|
      date_weight = self.recent_average_history_depth - (Date.today - date_of_act).numerator + 1
      point_numerator += date_weight * acts_on_date.map(&:points).compact.sum
    end

    point_denominator = (1..self.recent_average_history_depth + 1).sum
    self.recent_average_points = (point_numerator.to_f / point_denominator).ceil

    # Remember we're deliberately skipping callbacks here because we
    # anticipate updating rankings all in a batch.
    @batch_updating_recent_averages = true
    self.save
    @batch_updating_recent_averages = false
  end

  def self.claim_code_prefix(user)
    begin
      names = user.name.downcase.split.map(&:remove_non_words)
      first_name = names.first
      last_name = names.last
      [first_name.first, last_name].join('')
    rescue StandardError => e
      Rails.logger.error("ERROR IN .CLAIM_CODE_PREFIX")
      Rails.logger.error("FULL NAME: #{names.inspect}")
      Rails.logger.error("FIRST NAME: #{first_name}")
      Rails.logger.error("LAST NAME: #{last_name}")
      raise e
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
    Friendship.transaction do
      return nil unless self.demo.game_open?
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

  def self.claimable_by_email_address(claim_string)
    normalized_email = claim_string.gsub(/\s+/, '')
    User.find(:first, :conditions => ["email ILIKE ? AND claim_code != ''", normalized_email])
  end

  def self.claimable_by_first_name_and_claim_code(claim_string)
    normalized_claim_string = claim_string.downcase.gsub(/\s+/, ' ').strip
    first_name, claim_code = normalized_claim_string.split
    return nil unless (first_name && claim_code)
    User.where(["name ILIKE ? AND claim_code = ?", first_name + '%', claim_code]).first
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
      :default    => "told %{name} about the %{rule_value} command", 
      :name       => self.name, 
      :rule_value => rule_value.value
    )

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
      :point_and_ranking_summary => referring_user.point_and_ranking_summary
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
