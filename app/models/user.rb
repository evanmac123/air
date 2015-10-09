require 'digest/sha1'

class User < ActiveRecord::Base
  PRIVACY_LEVELS = %w(everybody connected nobody).freeze

  GENDERS = ["female", "male", "other", nil].freeze
  ROLES = ['User', 'Administrator'].freeze
  DEFAULT_MUTE_NOTICE_THRESHOLD = 10

  FIELDS_TRIGGERING_SEGMENTATION_UPDATE = %w(characteristics points location_id date_of_birth gender demo_id accepted_invitation_at last_acted_at phone_number email)

  MISSING_AVATAR_PATH = "/assets/avatars/thumb/missing.png"
  TAKEN_PHONE_NUMBER_ERR_MSG = "Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com"
  UNMONITORED_MAILBOX_RESPONSE_THRESHOLD = ENV['UNMONITORED_MAILBOX_RESPONSE_THRESHOLD'].try(:to_i) || 3600 # seconds

  include Clearance::User
  include User::Segmentation
  include ActionView::Helpers::TextHelper
  include CancelAccountToken

  extend User::Queries
  extend ValidImageMimeTypes

  belongs_to :location
  belongs_to :game_referrer, :class_name => "User"
  belongs_to :spouse, :class_name => "User"
  has_many   :acts, :dependent => :destroy, :as => :user
  has_many   :friendships, :dependent => :destroy
  has_many   :friends, :through => :friendships
  has_many   :tile_completions, :dependent => :destroy, :as => :user
  has_many   :completed_tiles, source: :tile, through: :tile_completions
  has_many   :unsubscribes, :dependent => :destroy
  has_many   :peer_invitations_as_invitee, :class_name => "PeerInvitation", as: :invitee
  has_many   :peer_invitations_as_inviter, :class_name => "PeerInvitation", :foreign_key => :inviter_id
  has_many   :tiles, :foreign_key => :creator_id
  has_many   :user_tile_copies, dependent: :destroy
  has_many   :user_tile_likes, dependent: :destroy
  has_many   :creator_tile_completions, source: :tile_completions, through: :tiles
  has_many   :board_memberships, dependent: :destroy
  has_many   :demos, through: :board_memberships
  has_many   :user_in_raffle_infos, as: :user
  has_many   :tile_viewings, as: :user
  has_many   :viewed_tiles, through: :tile_viewings, source: :tile
  has_many   :parent_board_users
  has_one    :raffle, through: :demo
  has_one    :current_board_membership, :class_name => "BoardMembership", :conditions => "is_current = true"
  has_one    :demo, through: :current_board_membership
  has_one    :original_guest_user, :class_name => "GuestUser", :foreign_key => :converted_user_id, :inverse_of => :converted_user
  has_one    :billing_information
  validate :normalized_phone_number_unique, :normalized_new_phone_number_unique, :normalized_new_phone_number_not_taken_by_board
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

  validates_length_of :password, :minimum => 6, :allow_blank => true, :message => 'must have at least 6 characters', :unless => :converting_from_guest
  validates :email, :with => :email_distinct_from_all_overflow_emails
  validates :overflow_email, :with => :overflow_email_distinct_from_all_emails

  validates_presence_of :password, :if => :converting_from_guest, :message => "Please enter a password at least 6 characters long"
  validates_length_of :password, :minimum => 6, :if => :converting_from_guest, :message => "Please enter a password at least 6 characters long"
  validates_presence_of :email, :if => :converting_from_guest, :message => "Please enter a valid email address"
  validates_presence_of :location_id, if: :must_have_location

  validates_with EmailFormatValidator, if: Proc.new {|u| u.invitation_method == :client_admin_invites}
  validates_presence_of :email, :if => :creating_board, :message => "can't be blank"
  validates_presence_of :password, :if => :creating_board, :message => "please enter a password at least 6 characters long"

  has_attached_file :avatar,
    :styles => {:thumb => ["96x96#", :png]},
    :default_style => :thumb,
    #:processors => [:png],
    :storage => :s3,
    :s3_credentials => S3_CREDENTIALS,
    :s3_headers => {'Expires' => 1.year.from_now.httpdate, 'Cache-Control' => 'max-age=315576000'},
    :s3_protocol => 'https',
    :path => "/avatars/:id/:style/:filename",
    :bucket => S3_AVATAR_BUCKET,
    :default_url => MISSING_AVATAR_PATH

  validates_attachment_content_type :avatar, content_type: valid_image_mime_types, message: invalid_mime_type_error

  serialize :flashes_for_next_request
  serialize :characteristics

  before_validation do
    # NOTE: This method is only called when you actually CALL the create method
    # (Not when you ask if the method is valid :on => :create.)
    # creating a new object and testing x.valid? :on => :create does not send us to this function
    set_slugs_based_on_name if name_present? && (self.slug.blank? || self.sms_slug.blank?)
  end


  before_validation do
    downcase_sms_slug
  end

  before_validation do
    if @role.present?
      self.is_client_admin = self.role == 'Administrator'
      if self.current_board_membership
        self.current_board_membership.is_client_admin = self.is_client_admin
        self.current_board_membership.save
      end
      true
    else
      true
    end
  end

  before_create do
    set_invitation_code
    set_explore_token
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

  attr_accessor :password_confirmation, :converting_from_guest, :must_have_location, :creating_board, :role

  # Changed from attr_protected to attr_accessible to address vulnerability CVE-2013-0276

  attr_accessible :name, :email, :invited, :demo_id, :created_at, :updated_at, :invitation_code, :phone_number, :points, :encrypted_password, :salt, :remember_token, :slug, :claim_code, :confirmation_token, :won_at, :sms_slug, :last_suggested_items, :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at, :ranking_query_offset, :accepted_invitation_at, :game_referrer_id, :notification_method, :location_id, :new_phone_number, :new_phone_validation, :date_of_birth, :gender, :session_count, :privacy_level, :last_muted_at, :last_told_about_mute, :mt_texts_today, :suppress_mute_notice, :follow_up_message_sent_at, :flashes_for_next_request, :characteristics, :overflow_email, :tickets, :zip_code, :is_employee, :ssn_hash, :employee_id, :spouse_id, :last_acted_at, :ticket_threshold_base, :terms_and_conditions, :get_started_lightbox_displayed, :send_weekly_activity_report
  #attr_protected :is_site_admin, :is_client_admin, :invitation_method

  has_alphabetical_column :name

  scope :non_admin, -> {where('users.is_site_admin <> ? AND users.is_client_admin <> ?', true, true)}

  def demo_id
    self.demo.id
  end

  def email_optional?
    true if phone_number
  end

  def role
    @role ||= begin
      if self.is_client_admin || (self.current_board_membership && self.current_board_membership.is_client_admin)
        'Administrator'
      else
        'User'
      end
    end
  end

  def role_in(demo)
    board_membership = self.board_memberships.find_by_demo_id(demo.id)
    if board_membership && board_membership.is_client_admin
      'Administrator'
    else
      'User'
    end
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
    # HRFF: check this only if the slug actually changed

    all_commands = SpecialCommand.reserved_words
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
      reason = " only allows connections to see their activity"
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

  def has_friends
    accepted_friends.count > 0
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
    OutgoingMessage.send_message self.new_phone_number, "Your code to verify this phone with Airbo is #{self.new_phone_validation}.", nil, :from_demo => self.demo
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
      OutgoingMessage.send_message(
        self,
        "If you want to temporarily stop getting texts from us, you can text back MUTE to stop them for 24 hours. To stop getting this reminder, text OK.",
        nil,
        channel: "sms"
      )
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

  def mixpanel_distinct_id
    attributes["mixpanel_distinct_id"] || self.id
  end

  def data_for_mixpanel
    {
      distinct_id:           self.mixpanel_distinct_id,
      id:                    self.id,
      email:                 (self.is_client_admin ? self.email : nil),
      game:                  self.demo_id,
      score:                 self.points,
      account_creation_date: self.created_at.to_date,
      joined_game_date:      self.accepted_invitation_at.try(:to_date),
      location:              self.location.try(:name),
      user_type:             self.highest_ranking_user_type,
      is_test_user:          !!(self.is_test_user), # remember, the !! normalized nil to false
      board_type:            (self.demo.try(:is_paid) ? "Paid" : "Free"),
      first_time_user:       false
    }
  end

  def add_board(board_or_board_id, is_current = false)
    board_id = board_or_board_id.kind_of?(Demo) ? board_or_board_id.id : board_or_board_id
    return if self.in_board?(board_id)
    self.board_memberships.create(demo_id: board_id, is_current: is_current)
    reload
    schedule_segmentation_update(true)
  end

  def remove_board(board_or_board_id)
    RemoveUserFromBoard.new(self, board_or_board_id).remove!
    schedule_segmentation_update(true)
  end

  def in_board?(demo_id)
    board_memberships.where(demo_id: demo_id).present?
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
    _demo = options[:demo_id].present? ? Demo.find(options[:demo_id]) : self.demo

    if referrer && !(options[:ignore_invitation_limit])
      peer_num = self.peer_invitations_as_invitee.where(demo: _demo).length
      return if peer_num >= PeerInvitation::CUTOFF
    end

    unless options[:is_new_invite]
      Mailer.delay_mail(:invitation, self, referrer, options)
    else
      TilesDigestMailer.delay.notify_one(_demo.id, id,
        _demo.digest_tiles(nil).pluck(:id), "Join my #{_demo.name}", false, nil,
        options[:custom_message], options[:custom_from], options[:is_new_invite])
    end
    if referrer && !(options[:ignore_invitation_limit])
      PeerInvitation.create!(inviter: referrer, invitee: self, demo: referrer.demo)
    end

    update_attributes(invited: true)
  end

  def invitable?
    email.present?
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

  def join_game(reply_mode=:string)
    mark_as_claimed
    finish_claim(reply_mode)
  end

  def record_claim_in_mixpanel(channel)
    TrackEvent.ping('claimed account', {:channel => channel}, self)
  end

  def update_points(point_increment, channel=nil)
    original_tickets = self.tickets
    PointIncrementer.new(self, point_increment).update_points
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

  def set_explore_token
    self.explore_token = Digest::SHA1.hexdigest("This is the salt for an explore token, how about that--#{Time.now.to_f}--#{self.email}--#{self.name}--")
  end

  def set_explore_token! # useful for backfilling
    set_explore_token
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

  def point_and_ticket_summary(prefix = [])
    User::PointAndTicketSummarizer.new(self).point_and_ticket_summary(prefix)
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

  def member_of_demo?(demo)
    demos.include?(demo)
  end

  def move_to_new_demo(new_demo_or_id)
    new_demo = new_demo_or_id.kind_of?(Demo) ? new_demo_or_id : Demo.find(new_demo_or_id)

    Demo.transaction do
      unless member_of_demo?(new_demo)
        if is_site_admin
          add_board(new_demo)
        else
          return false
        end
      end

      # We denormalize a little here, rather than delegate to the board
      # memberships, in the interest of backwards compatibility. Some of
      # the attributes we're messing with here are relevant to client
      # admin authorization, so we want to keep using the proven code for
      # that.
      save_current_board_dependent_attributes
      board_memberships.current.each{|board_membership| board_membership.update_attributes(is_current: false)}
      new_board_membership = board_memberships.where(demo_id: new_demo.id).first
      new_board_membership.update_attributes(is_current:true)
      load_updated_board_dependent_attributes(new_board_membership)

      self.save!
    end

    board_memberships.reload
    true
  end

  def befriend(other, mixpanel_properties={})
    friendship = nil
    Friendship.transaction do
      return nil if self.friendships.where(:friend_id => other.id).present?
      friendship = self.friendships.create(:friend_id => other.id, :state => 'initiated')
      reciprocal_friendship = other.friendships.create(:friend_id => self.id, :state => 'pending')
      reciprocal_friendship.update_attribute(:request_index, friendship.request_index)
    end

    friendship
  end

  def accept_friendship_from(other)
    Friendship.where(:user_id => other.id, :friend_id => self.id).first.accept
  end

  def follow_requested_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      :default => "OK, you'll be connected with %{followed_user_name}, pending %{her_his} acceptance.",
      :followed_user_name => self.name,
      :her_his => self.her_his
    )
  end


  def follow_removed_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      :default => "OK, you're no longer connected to %{followed_user_name}.",
      :followed_user_name => self.name
    )
  end

  def email_with_name
    "#{name} <#{email}>"
  end

  def email_with_name_via_airbo
    "#{name} via Airbo <#{email}>"
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

  def profile_page_friends_list
    self.accepted_friends.sort_by {|ff| ff.name.downcase}
  end

  def scoreboard_friends_list_by_tickets
    (self.accepted_friends + [self]).sort_by(&:tickets).reverse
  end

  def scoreboard_friends_list_by_name
    (self.accepted_friends + [self]).sort_by {|ff| ff.name.downcase}
  end

  def reset_tiles(demo=nil)
    demo ||= self.demo

    # Why the fuck does changing this to self.tile_completions not work?
    TileCompletion.where(user_id: self.id).each do |completion|
      completion.destroy if completion.tile.demo == demo
    end
  end

  def has_tiles_tools_subnav?
    is_client_admin || is_site_admin
  end

  def self.send_invitation_if_claimed_sms_user_texts_us_an_email_address(from_phone, text, options={})
    return nil unless from_phone =~ /^(\+1\d{10})$/

    _text = text.downcase.strip.gsub(" ", "")
    return nil unless _text.is_email_address?

    user = User.where(phone_number: from_phone).first

    return "No user found with phone number #{from_phone}. Please try again, or contact support@airbo.com for help" unless user
    return "Please text us your claim code first" unless user.claimed?


    user.load_personal_email(_text)
    return "The email #{_text} #{user.errors.messages[:email].first}." unless user.errors.blank?
    options_password_only = options.merge(password_only: true)
    user.reload.invite(nil, options_password_only)
    return user.invitation_sent_text
  end

  def send_conversion_email
    Mailer.delay_mail(:guest_user_converted_to_real_user, self)
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
    TrackEvent.ping(event, data)
  end

  def ping_page(page, additional_properties={})
    event = 'viewed page'
    properties = {page_name: page}.merge(additional_properties)
    ping(event, properties)
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

  # Activity feed posts when someone joins are "joined the game", "credited [name] for referring them to the game" and "got credit for referring [name] to the game." Suggestions: "joined", "credited [name] for recruiting them" and "got credit for recruiting [name]"
  def credit_game_referrer(referring_user)
    referring_user = User.where(id: referring_user).first
    return unless referring_user

    demo = self.demo

    referrer_act_text = I18n.t('special_command.credit_game_referrer.activity_feed_text', :default => "got credit for recruiting %{referred_name}", :referred_name => self.name)
    referrer_sms_text = I18n.t('special_command.credit_game_referrer.referrer_sms', :default => "%{referred_name} gave you credit for recruiting them. Many thanks and %{points} bonus points!", :referred_name => self.name, :points => demo.game_referrer_bonus)

    referred_act_text = I18n.t('special_command.credit_game_referrer.referred_activity_feed_text', :default => "credited %{referrer_name} for recruiting them", :referrer_name => referring_user.name)
    referred_sms_points_phrase = case demo.referred_credit_bonus
                                 when nil
                                   ""
                                 when 1
                                   " (and 1 point)"
                                 else
                                   " (and #{demo.referred_credit_bonus} points)"
                                 end
    referred_sms_text = I18n.t('special_command.credit_game_referrer.referred_sms', :default => "Got it, %{referrer_name} recruited you. Thanks%{points_phrase} for letting us know.", :referrer_name => referring_user.name, :points_phrase => referred_sms_points_phrase)

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
    when :explore_family
      is_site_admin || is_client_admin_in_any_board
    else
      false
    end
  end

  def to_ticket_progress_calculator
    TicketProgressCalculator.new(self)
  end

  def on_first_login
    session_count == 1
  end

  def self.find_by_either_email(email)
    email = email.strip.downcase
    where("email = ? OR overflow_email = ?", email, email).first
  end

  def is_guest?
    false
  end

  def highest_ranking_user_type
    return "site admin" if self.is_site_admin
    return "client admin" if self.is_client_admin
    "ordinary user"
  end

  def mark_own_tile_completed(tile)
    self.has_own_tile_completed = true
    self.has_own_tile_completed_displayed = false
    self.has_own_tile_completed_id = tile.id
    self.save!
    Mailer.delay(run_at: 15.minutes.from_now).congratulate_creator_with_first_completed_tile(self)
  end

  def can_start_over?
    false
  end

  def non_current_boards
    current_demo_id = demo_id
    demos.where(id: demo_ids - [current_demo_id])
  end

  def is_client_admin_in_board(board)
    if board == self.demo
      self.is_client_admin
    else
      board_memberships.find_by_demo_id(board.id).try(:is_client_admin)
    end
  end

  def current_location_in_board(board)
    if board == self.demo
      self.location
    else
      board_memberships.find_by_demo_id(board.id).try(:location)
    end
  end

  def flush_tickets_in_board(board_id)
    User.transaction do
      if demo_id == board_id
        update_attributes(tickets: 0, ticket_threshold_base: points)
      else
        board_membership = board_memberships.find_by_demo_id(board_id)
        board_membership.update_attributes(tickets: 0, ticket_threshold_base: board_membership.points)
      end
    end
  end

  def has_board_in_common_with(other_user)
    board_ids = self.board_memberships.pluck(:demo_id)
    other_user.board_memberships.where(demo_id: board_ids).first.present?
  end

  def likes_tile?(tile)
    tile.user_tile_likes.where(user_id: self.id).exists?
  end

  def copied_tile?(tile)
    tile.user_tile_copies.where(user_id: self.id).exists?
  end

  def available_tiles_on_current_demo
    TileProgressCalculator.new(self).available_tiles_on_current_demo
  end

  def completed_tiles_on_current_demo
    TileProgressCalculator.new(self).completed_tiles_on_current_demo
  end

  def not_show_all_completed_tiles_in_progress
    TileProgressCalculator.new(self).not_show_all_completed_tiles_in_progress
  end

  def show_onboarding?
    # onboarding is already turned off
    if self.current_board_membership.not_show_onboarding
      false
    # onboarding is turned off for board. so turn off it for admin
    elsif (self.is_client_admin || self.is_site_admin)
      self.current_board_membership.update_attribute(:not_show_onboarding, true)
      self.get_started_lightbox_displayed = true
      self.displayed_activity_page_admin_guide = true
      self.save!
      false
    else
      true
    end
  end

  def is_client_admin_in_any_board
    is_client_admin || board_memberships.pluck(:is_client_admin).any?
  end

  def can_switch_boards?
    true
  end

  def can_open_board_settings?
    true
  end

  def nerf_links_with_login_modal?
    false
  end

  def boards_as_admin
    # OPTZ: Accidentally wrote an N+1 query here, whoops. Fix this up with
    # some joins/includes.
    User.transaction do
      boards = board_memberships.where(is_client_admin: true, is_current: false).map(&:demo)

      if is_client_admin || is_site_admin
        boards << demo
      end

      boards
    end
  end

  def boards_as_regular_user
    User.transaction do
      boards = board_memberships.where(is_client_admin: false, is_current: false).map(&:demo)

      unless is_client_admin || is_site_admin
        boards << demo
      end

      boards
    end
  end

  def has_only_one_board?
    demos.limit(2).count == 1
  end

  def muted_digest_boards
    self.board_memberships.where(digest_muted: true).map(&:demo)
  end

  def muted_followup_boards
    self.board_memberships.where(followup_muted: true).map(&:demo)
  end

  def has_only_board?(board)
    demos == [board]
  end

  def not_in_any_paid_boards?
    demos.where(is_paid: true).first.nil?
  end

  def voteup_intro_never_seen
    !(voteup_intro_seen)
  end

  def share_link_intro_never_seen
    !(share_link_intro_seen)
  end

  def can_see_raffle_modal?
    true
  end

  def in_multiple_boards?
    demo_ids.length > 1
  end

  def have_access_to_parent_board?(board)
    board = Demo.where(id: board).first unless board.is_a? Demo
    board && board.is_parent && is_site_admin
  end

  def display_get_started_lightbox
    on_first_login \
    && !get_started_lightbox_displayed \
    && demo.tiles.active.present? \
    && show_onboarding?
  end

  def is_parent_board_user?
    false
  end

  def copy_active_tiles_from_demo(demo)
    CopyTile.new(self.demo, self).copy_active_tiles_from_demo(demo)
  end

  def too_soon_for_another_unmonitored_mailbox_reminder?
    return false if self.last_unmonitored_mailbox_response_at.nil?
    Time.now - self.last_unmonitored_mailbox_response_at < UNMONITORED_MAILBOX_RESPONSE_THRESHOLD
  end

  def update_allowed_to_make_tile_suggestions value, demo
    bm = board_memberships.where(demo: demo).first
    return unless bm
    transaction do
      bm.update_attribute :allowed_to_make_tile_suggestions, value
      if bm.is_current
        update_attribute :allowed_to_make_tile_suggestions, value
      end
    end
  end

  def can_make_tile_suggestions? _demo = demo
    bm = board_memberships.where(demo: _demo).first
    _demo.everyone_can_make_tile_suggestions ||
      bm.allowed_to_make_tile_suggestions
  end

  def self.allow_to_make_tile_suggestions _user_ids, _demo
    transaction do
      BoardMembership
        .where(demo: _demo, allowed_to_make_tile_suggestions: true)
        .update_all(allowed_to_make_tile_suggestions: false)

      BoardMembership
        .where do
          (user_id.in _user_ids) &
          (demo == _demo)
        end
        .update_all(allowed_to_make_tile_suggestions: true)

      joins{board_memberships}
        .where do
          (board_memberships.demo == _demo) &
          (board_memberships.is_current == true) &
          (allowed_to_make_tile_suggestions == true)
        end
        .update_all(allowed_to_make_tile_suggestions: false)

      joins{board_memberships}
        .where do
          (board_memberships.demo == _demo) &
          (board_memberships.is_current == true) &
          (id.in _user_ids)
        end
        .update_all(allowed_to_make_tile_suggestions: true)
    end
  end

  def self.allowed_to_suggest_tiles _demo
    joins{board_memberships}
      .where do
        (board_memberships.demo == _demo) &
        (board_memberships.allowed_to_make_tile_suggestions == true)
      end
  end

  def show_submit_tile_intro!
    if can_make_tile_suggestions? && !submit_tile_intro_seen
      update_attribute :submit_tile_intro_seen, true
      true
    end
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
      self.errors.add(input, TAKEN_PHONE_NUMBER_ERR_MSG)
    end
  end

  def normalized_new_phone_number_not_taken_by_board
    num = PhoneNumber.normalize(new_phone_number)
    return unless num.present?

    found = Demo.find_by_phone_number(num)
    if found
      self.errors.add(:new_phone_number, TAKEN_PHONE_NUMBER_ERR_MSG)
      return false
    else
      true
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

  # See note in #move_to_new_demo for why these next two exist.
  FIELDS_ON_A_BOARD_BY_BOARD_BASIS = %w(is_client_admin points tickets ticket_threshold_base location_id displayed_tile_post_guide displayed_tile_success_guide allowed_to_make_tile_suggestions)
  def save_current_board_dependent_attributes
   _current_board_membership = current_board_membership
    FIELDS_ON_A_BOARD_BY_BOARD_BASIS.each do |field|
      current_value = self.send(field)
      _current_board_membership.send("#{field}=", current_value)
    end

    _current_board_membership.save!
  end

  def load_updated_board_dependent_attributes(new_board_membership)
     FIELDS_ON_A_BOARD_BY_BOARD_BASIS.each do |field|
      current_value = new_board_membership.send(field)
      send("#{field}=", current_value)
    end

    save!
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
      :text            => 'joined!',
      :inherent_points => user.demo.seed_points
    )
  end

  def add_joining_to_activity_stream
    self.class.add_joining_to_activity_stream(self)
  end

  def self.passwords_dont_match_error_message
    "Sorry, your passwords don't match"
  end
end
