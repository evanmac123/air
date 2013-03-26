require 'digest/sha1'

class User < ActiveRecord::Base
  # Maximum number of days back we will consider acts in the moving average
  # (counting today as day 0)
  PRIVACY_LEVELS = %w(everybody connected nobody).freeze

  GENDERS = ["female", "male", "other", nil].freeze

  DEFAULT_MUTE_NOTICE_THRESHOLD = 10

  FIELDS_TRIGGERING_SEGMENTATION_UPDATE = %w(characteristics points location_id date_of_birth gender demo_id accepted_invitation_at last_acted_at phone_number email)

  include Clearance::User
  include User::Segmentation
  include ActionView::Helpers::TextHelper
  extend User::Queries
  extend Sequenceable

  belongs_to :demo
  belongs_to :location
  belongs_to :game_referrer, :class_name => "User"
  belongs_to :spouse, :class_name => "User"
  has_many   :acts, :dependent => :destroy
  has_many   :friendships, :dependent => :destroy
  has_many   :friends, :through => :friendships
  has_many   :survey_answers
  has_many   :goal_completions
  has_many   :completed_goals, :through => :goal_completions, :source => :goal
  has_many   :timed_bonuses, :class_name => "TimedBonus"
  has_many   :tile_completions, :dependent => :destroy
  has_many   :unsubscribes, :dependent => :destroy
  has_many   :peer_invitations_as_invitee, :class_name => "PeerInvitation", :foreign_key => :invitee_id
  has_many   :peer_invitations_as_inviter, :class_name => "PeerInvitation", :foreign_key => :inviter_id
  has_one   :tutorial, :dependent => :destroy

  validate :normalized_phone_number_unique, :normalized_new_phone_number_unique
  validate :new_phone_number_has_valid_number_of_digits
  validate :sms_slug_does_not_match_commands
  validate :date_of_birth_in_the_past

  validates_uniqueness_of :slug
  validates_uniqueness_of :sms_slug, :message => "Sorry, that username is already taken."
  validates_uniqueness_of :overflow_email, :allow_blank => true
  # validates_uniqueness_of :email comes from Clearance
  validates_uniqueness_of :invitation_code, :allow_blank => true

  validates_presence_of :name, :message => "Please enter a first and last name"
  validates_presence_of :sms_slug, :if => :name_present?, :message => "Please choose a username"
  validates_presence_of :slug, :if => :name_present?
  
  validates_presence_of :privacy_level
  validates_inclusion_of :privacy_level, :in => PRIVACY_LEVELS

  validates_inclusion_of :gender, :in => GENDERS, :allow_blank => true

  validates_format_of :slug, :with => /^[0-9a-z]+$/, :if => :name_present?
  validates_format_of :sms_slug, :with => /^[0-9a-z]{2,}$/,
                      :message => "Sorry, the username must consist of letters or digits only.",
                      :if => :name_present?

  validates_format_of :zip_code, with: /^\d{5}$/, allow_blank: true

  validates_presence_of :demo_id

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
    :bucket => S3_AVATAR_BUCKET,
    :default_url => "/assets/avatars/thumb/missing.png"

  serialize :flashes_for_next_request
  serialize :characteristics

  before_validation do
    # NOTE: This method is only called when you actually CALL the create method
    # (Not when you ask if the method is valid :on => :create.)
    # creating a new object and testing x.valid? :on => :create does not send us to this function
    unless trying_to_accept
      set_slugs_based_on_name if name_present? && (self.slug.blank? || self.sms_slug.blank?)
    end
  end


  before_validation do
    downcase_sms_slug
  end

  before_create do
    set_invitation_code
  end

  before_save do
    downcase_email
    cast_characteristics
  end

  after_save do
    sync_spouses
  end

  after_create do
    schedule_segmentation_create
  end

  after_update do
    schedule_segmentation_update
    update_associated_act_privacy_levels
  end

  after_destroy do
    destroy_friendships_where_secondary
    destroy_segmentation_info
  end

  attr_accessor :trying_to_accept, :password_confirmation

  # Changed from attr_protected to attr_accessible to address vulnerability CVE-2013-0276
  
  attr_accessible :name, :email, :invited, :demo_id, :created_at, :updated_at, :invitation_code, :phone_number, :points, :encrypted_password, :salt, :remember_token, :slug, :claim_code, :confirmation_token, :won_at, :sms_slug, :last_suggested_items, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :ranking_query_offset, :accepted_invitation_at, :game_referrer_id, :notification_method, :location_id, :new_phone_number, :new_phone_validation, :date_of_birth, :gender, :session_count, :privacy_level, :last_muted_at, :last_told_about_mute, :mt_texts_today, :suppress_mute_notice, :follow_up_message_sent_at, :flashes_for_next_request, :characteristics, :overflow_email, :tickets, :zip_code, :is_employee, :ssn_hash, :employee_id, :spouse_id, :last_acted_at, :ticket_threshold_base, :terms_and_conditions
  #attr_protected :is_site_admin, :is_client_admin, :invitation_method

  has_alphabetical_column :name

  def email_optional?
    true if phone_number
  end

  def update_last_acted_at
    reload if changed? # Let's scrap any dirty changes so we don't get unwanted side-effects
    self.last_acted_at = Time.now
    save!
  end

  def corporate_email
    return email if overflow_email.empty?
    overflow_email
  end
  
  def email_distinct_from_all_overflow_emails
    return if email.blank? && overflow_email.blank?
    if email.blank? && overflow_email.present?
      self.errors.add(:email, 'must have a primary email if you have a secondary email')
    else
      # HRFF: no need to check this unless emails changed
      users_with_your_email = User.where(overflow_email: email).reject{|ff| ff == self}
      self.errors.add(:email, "'#{email}' is already taken") if users_with_your_email.present?
    end
  end

  def overflow_email_distinct_from_all_emails
    return if overflow_email.blank? 
    # HRFF: no need to check this unless emails changed
    if User.where(email: overflow_email).reject{|ff| ff == self}.present?
      self.errors.add(:overflow_email, 'someone else has your secondary email as their primary email')
    end
    if email == overflow_email
      self.errors.add(:overflow_email, 'your primary and secondary emails cannot be the same')
    end
  end

  def sms_slug_does_not_match_commands
    if self.demo && self.demo.rule_values.present?
      demo_rules = self.demo.rule_values
      demo_rule_values = demo_rules.collect do |v|
        v.value
      end
    else
      demo_rule_values = []
    end
    
    all_commands = SpecialCommand.reserved_words + demo_rule_values
    if all_commands.include? self.sms_slug
      self.errors.add("sms_slug", "Sorry, but that username is reserved")
    end
  end

  def date_of_birth_in_the_past
    return unless self.date_of_birth

    unless self.date_of_birth < Date.today
      self.errors.add(:date_of_birth, "must be in the past")
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

  def send_support_request
    latest_act_descriptions = IncomingSms.where(:from => self.phone_number).order("created_at DESC").limit(20).map(&:body)

    Mailer.delay_mail(:support_request, self.name, self.email, self.phone_number, self.demo.name, latest_act_descriptions)
  end

  def first_eligible_rule_value(value)
    RuleValue.visible_from_demo(self).where(:value => value).first
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
    self.delay(:run_at => Time.now + demo.followup_welcome_message_delay.minutes).send_followup_welcome_message
  end

  def send_followup_welcome_message
    User.transaction do
      unless self.follow_up_message_sent_at
        OutgoingMessage.send_message(self, self.demo.followup_welcome_message, nil, just_message: true)
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
      OutgoingMessage.send_message(self, "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text OK.")
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
    self.demo.reply_email_address(include_name)
  end

  def data_for_mixpanel
    {
      :distinct_id           => self.id,
      :id                    => self.id,
      :email                 => self.email,
      :game                  => self.demo.name,
      :following_count       => Friendship.accepted.where(:user_id => self.id).count,
      :followers_count       => Friendship.accepted.where(:friend_id => self.id).count,
      :score                 => self.points,
      :account_creation_date => self.created_at.to_date,
      :joined_game_date      => self.accepted_invitation_at.try(:to_date),
      :location              => self.location.try(:name)
    }
  end

  def schedule_rule_suggestion_mixpanel_ping
    suggestion_ids = self.last_suggested_items.present? ? self.last_suggested_items.split('|') : []
    suggestion_hash = Hash[*([:suggestion_a, :suggestion_b, :suggestion_c].zip(suggestion_ids).flatten)]

    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("got rule suggestion", data_for_mixpanel.merge(suggestion_hash))
  end

  def email_has_internal_domain?
    return false unless (self.email.present?) && (self.email =~ /@(.*)$/)
    domain = $1.downcase
    self.demo.internal_domains.include? domain
  end

  def self.claim_account(from, to, claim_code, options={})
    channel = options[:channel] || :sms

    claimer_class = case channel
    when :sms
      AccountClaimer::SMSClaimer
    when :email
      AccountClaimer::EmailClaimer
    end

    claimer_class.new(from, to, claim_code, options).claim
  end

  def invite(referrer = nil, options ={})
    return if referrer && self.peer_invitations_as_invitee.length >= PeerInvitation::CUTOFF

    Mailer.delay_mail(:invitation, self, referrer, options)

    if referrer
      PeerInvitation.create!(inviter: referrer, invitee: self, demo: referrer.demo)
    end

    update_attributes(invited: true)
  end

  def mark_as_claimed(options={})
    _options = {:channel => :web}.merge(options)
    channel = _options[:channel]
    phone_number = _options[:phone_number]
    email = _options[:email]

    update_attribute(:phone_number, PhoneNumber.normalize(phone_number)) if phone_number.present?
    update_attribute(:email, email) if email.present?
    update_attribute(:accepted_invitation_at, Time.now)
    record_claim_in_mixpanel(channel)
  end

  def finish_claim(reply_mode = :string)
    add_joining_to_activity_stream
    schedule_followup_welcome_message

    welcome_message = demo.welcome_message(self)

    case reply_mode
    when :send
      OutgoingMessage.send_message(self, welcome_message, nil, just_message: true)
    when :string
      welcome_message
    end
  end

  def join_game(number, reply_mode=:string)
    mark_as_claimed(:phone_number => number)
    finish_claim(reply_mode)
  end

  def record_claim_in_mixpanel(channel)
    Mixpanel::Tracker.new(MIXPANEL_TOKEN, {}).delay.track("claimed account", {:channel => channel}.merge(self.data_for_mixpanel))
  end

  def update_points(point_increment, channel=nil)
    old_points = self.points
    increment!(:points, point_increment)

    new_points = self.points
    add_ticket(old_points, new_points, channel)
  end

  def password_optional?
    true
  end

  def set_invitation_code
    possibly_finished = false

    until(possibly_finished && (self.valid? || self.errors[:invitation_code].empty?))
      possibly_finished = true
      self.invitation_code = Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{self.email}--#{self.name}--")
    end
  end

  def set_invitation_code!
    set_invitation_code
    save!
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

  def point_summary
    if self.demo.ticket_threshold > 0
      "points #{self.to_ticket_progress_calculator.pretty_point_fraction}"
    else
      "points #{self.points}"
    end
  end

  def ticket_summary
    "Tix #{self.tickets}"
  end

  def point_and_ticket_summary(prefix = [])
    return "" unless self.demo.use_post_act_summaries

    result_parts = prefix.clone
    result_parts << self.point_summary
    result_parts << self.ticket_summary

    ' ' + result_parts.map(&:capitalize).compact.join(', ') + '.'
  end

  def claim_code_prefix
    self.class.claim_code_prefix(self)
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
    self.points = self.acts.where(:demo_id => new_demo_id).map(&:points).compact.sum
    self.save!
  end

  # Returns a list [reply, reply_type] where reply_type should be :success if
  # the action was successful, or an error code if the action failed.

  def act_on_rule(rule, rule_value, options={})
    self.last_suggested_items = ''
    self.save!

    result = nil

    User.transaction do
      if rule.user_hit_limit?(self)
        return ["Sorry, you've already done that action.", :over_alltime_limit]
      end

      if rule.user_hit_daily_limit?(self)
        return ["Sorry, you've reached the limit for the number of times you can earn points for that kind of action today. Enter it tomorrow!", :over_daily_limit]
      end
     
      result = [Act.record_act(self, rule, rule_value, options), :success]
    end

    credit_referring_user(options[:referring_user], rule, rule_value)
    result
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
    ping('fanned', mixpanel_properties) unless tutorial_active?

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

  def satisfy_tiles_by_survey(survey_or_survey_id, channel)
    satisfiable_tiles = Tile.satisfiable_by_survey_to_user(survey_or_survey_id, self)
    satisfiable_tiles.each do |tile|
      tile.satisfy_for_user!(self, channel) 
    end
  end

  def satisfy_tiles_by_rule(rule_or_rule_id, channel, referring_user_id = nil)
    return unless rule_or_rule_id

    satisfiable_tiles = Tile.satisfiable_by_rule_to_user(rule_or_rule_id, self)

    satisfiable_tiles.each do |tile|
      required = tile.rule_triggers.map(&:referrer_required).include? true
      if referring_user_id or not required
        tile.satisfy_for_user!(self, channel) if tile.all_rule_triggers_satisfied_to_user(self)
      end
    end
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
  
  def scoreboard_friends_list_by_tickets
    (self.accepted_friends_same_demo + [self]).sort_by(&:tickets).reverse
  end
  
  def scoreboard_friends_list_by_name
    (self.accepted_friends_same_demo + [self]).sort_by {|ff| ff.name.downcase}
  end

  def reset_tiles(demo=nil)
    demo ||= self.demo

    # Why the fuck does changing this to self.tile_completions not work?
    TileCompletion.where(user_id: self.id).each do |completion|
      completion.destroy if completion.tile.demo == demo
    end

    Tile.where(demo_id: demo.id).each do |tile|
      tile.rule_triggers.each do |rule_trigger|
        Act.where(user_id: self.id, rule_id: rule_trigger.rule_id).each { |act| act.destroy }
      end
    end
  end


  def self.send_invitation_if_claimed_sms_user_texts_us_an_email_address(from_phone, text, options={})
    return nil unless from_phone =~ /^(\+1\d{10})$/
    
    _text = text.downcase.strip.gsub(" ", "")
    return nil unless _text.is_email_address?
    
    user = User.where(phone_number: from_phone).first

    return "No user found with phone number #{from_phone}. Please try again, or contact support@hengage.com for help" unless user
    return "Please text us your claim code first" unless user.claimed?


    user.load_personal_email(_text)
    return "The email #{_text} #{user.errors.messages[:email].first}." unless user.errors.blank?
    options_password_only = options.merge(password_only: true)
    user.reload.invite(nil, options_password_only)
    return user.invitation_sent_text
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
    update_attributes(confirmation_token: SecureRandom.hex(16))
  end

  def ping(event, properties={})
    data = data_for_mixpanel.merge(properties) 
    Shotgun.ping(event, data)
  end

  def ping_page(page, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page}.merge(additional_properties)
    ping(event, properties)
  end

  def pinged_on_page?(page)
    return false unless Rails.env.test?
    FakeMixpanelTracker.has_event_matching?("viewed page", self.data_for_mixpanel.merge(page_name: page))
  end

  def load_personal_email(in_email)
    return nil unless in_email.try(:is_email_address?)
    return true if email == in_email # do nothing but return true if they try to reload their primary email
    update_attributes(overflow_email: email, email: in_email)
  end
 
  def bad_friendship_index_error_message(request_index)
    if request_index && Friendship.pending(self).present?
      "Looks like you already responded to that request, or didn't have a request with that number"
    else
      "You have no pending requests to add someone as a friend."
    end
  end

  def credit_game_referrer(referring_user)
    demo = self.demo

    referrer_act_text = I18n.t('special_command.credit_game_referrer.activity_feed_text', :default => "got credit for referring %{referred_name} to the game", :referred_name => self.name)
    referrer_sms_text = I18n.t('special_command.credit_game_referrer.referrer_sms', :default => "%{referred_name} gave you credit for referring them to the game. Many thanks and %{points} bonus points!", :referred_name => self.name, :points => demo.game_referrer_bonus)

    referred_act_text = I18n.t('special_command.credit_game_referrer.referred_activity_feed_text', :default => "credited %{referrer_name} for referring them to the game", :referrer_name => referring_user.name)
    referred_sms_points_phrase = case demo.referred_credit_bonus
                                 when nil
                                   ""
                                 when 1
                                   " (and 1 point)"
                                 else
                                   " (and #{demo.referred_credit_bonus} points)"
                                 end
    referred_sms_text = I18n.t('special_command.credit_game_referrer.referred_sms', :default => "Got it, %{referrer_name} referred you to the game. Thanks%{points_phrase} for letting us know.", :referrer_name => referring_user.name, :points_phrase => referred_sms_points_phrase)

    self.update_attribute(:game_referrer_id, referring_user.id)

    referring_user.acts.create!(
      :text            => referrer_act_text,
      :inherent_points => demo.game_referrer_bonus
    )

    self.acts.create!(
      :text            => referred_act_text,
      :inherent_points => demo.referred_credit_bonus
    )

    OutgoingMessage.send_message(referring_user, referrer_sms_text)

    referred_sms_text
  end

  def authorized_to?(page_class)
    case page_class.to_sym
    when :site_admin
      is_site_admin
    when :client_admin
      is_site_admin || is_client_admin
    else
      false
    end
  end

  def to_ticket_progress_calculator
    User::TicketProgressCalculator.new(self)
  end

  def self.find_by_either_email(email)
    email = email.strip.downcase
    where("email = ? OR overflow_email = ?", email, email).first
  end

  protected

  def downcase_email
    self.email = email.to_s.downcase
  end

  # Assumes spouse exists (or wouldn't be changing the spousal status)
  def sync_spouses
    if spouse_id_changed?
      my_spouse_id = spouse_id.nil? ? spouse_id_was : spouse_id
      my_spouse = User.find(my_spouse_id)
      my_spouse.update_attribute :spouse_id, spouse_id.nil? ? nil : id
    end
  end

  def destroy_friendships_where_secondary
    Friendship.destroy_all(:friend_id => self.id)
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

  def new_phone_number_has_valid_number_of_digits
    return unless self.new_phone_number.present?
    unless PhoneNumber.is_valid_number?(self.new_phone_number)
      self.errors.add(:new_phone_number, "Please fill in all ten digits of your mobile number, including the area code")
    end
  end

  def downcase_sms_slug
    return unless self.sms_slug
    self.sms_slug.downcase!
  end

  def name_present?
    # this is wrapped up like so so that we can use it in validations
    name.present?
  end

  def mute_notice_threshold
    self.demo.mute_notice_threshold || DEFAULT_MUTE_NOTICE_THRESHOLD
  end

  def update_associated_act_privacy_levels
    # See Act for an explanation of why we denormalize privacy_level onto it.
    Act.update_all({:privacy_level => self.privacy_level}, {:user_id => self.id}) if self.changed.include?('privacy_level')
  end

  def add_ticket(old_points, new_points, channel)
    return unless self.demo.uses_tickets

    old_point_tranche = ticket_tranche(old_points)
    new_point_tranche = ticket_tranche(new_points)

    if new_point_tranche > old_point_tranche
      self.increment!(:tickets)
      OutgoingMessage.send_side_message(self, "Congratulations - You've earned #{pluralize tickets, 'ticket'}!", channel: channel)
    end
  end

  def ticket_tranche(point_value)
    (point_value - ticket_threshold_base) / self.demo.ticket_threshold
  end

  def self.claimable_by_first_name_and_claim_code(claim_string)
    normalized_claim_string = claim_string.downcase.gsub(/\s+/, ' ').strip
    first_name, claim_code = normalized_claim_string.split
    return nil unless (first_name && claim_code)
    User.where(["name ILIKE ? AND claim_code = ?", first_name.like_escape + '%', claim_code]).first
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
      %{+%{points}, %{name} tagged you in the "%{rule_value}" command.%{point_and_ticket_summary}},
      :points                    => points_phrase,
      :name                      => self.name,
      :rule_value                => rule_value.value,
      :point_and_ticket_summary  => referring_user.point_and_ticket_summary
    )

    OutgoingMessage.send_message(referring_user, sms_text)
  end

  def self.passwords_dont_match_error_message
    "Sorry, your passwords don't match"
  end
end
