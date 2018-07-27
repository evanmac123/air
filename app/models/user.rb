# frozen_string_literal: true

require "digest/sha1"

class User < ActiveRecord::Base
  PRIVACY_LEVELS = %w(everybody connected nobody).freeze

  GENDERS = ["female", "male", "other", nil].freeze
  ROLES = ["User", "Administrator"].freeze

  FIELDS_TRIGGERING_SEGMENTATION_UPDATE = %w(characteristics points location_id date_of_birth gender demo_id accepted_invitation_at last_acted_at phone_number email)

  TAKEN_PHONE_NUMBER_ERR_MSG = "Sorry, but that phone number has already been taken. Need help? Contact support@airbo.com"

  MISSING_AVATAR_PATH = "avatar_missing.png"

  include Clearance::User
  include User::Segmentation
  include ActionView::Helpers::TextHelper
  include CancelAccountToken
  include User::ClientAdminNotifications
  include User::Tiles

  extend User::Queries

  belongs_to :location
  belongs_to :game_referrer, class_name: "User"
  belongs_to :spouse, class_name: "User"
  belongs_to :primary_user, class_name: "User"

  # Use destroy strategy to allow callbacks to run for these relations
  # ------------------------------------------------------------------
  has_one    :dependent_user,  class_name: "User", foreign_key: :primary_user_id, dependent: :destroy

  has_many   :potential_users, foreign_key: "primary_user_id", dependent: :destroy
  has_many   :tile_user_notifications, foreign_key: "creator_id"
  # Use delete strategy for direct unshared simple relations with no additional cleanup
  # required prevents callbacks and records being instantiated
  # ------------------------------------------------------------------

  has_one    :lead_contact, dependent: :delete
  has_one    :billing_information, dependent: :delete
  has_one    :user_intro, as: :userable, dependent: :delete # FIXME this is confusing since we have an intros method below
  has_one    :user_settings_change_log, dependent: :delete

  has_many   :peer_invitations_as_inviter, class_name: "PeerInvitation", foreign_key: :inviter_id, dependent: :delete_all
  has_many   :user_in_raffle_infos, as: :user, dependent: :delete_all
  has_many   :acts, as: :user, dependent: :delete_all
  has_many   :friendships, dependent: :delete_all
  has_many   :unsubscribes, dependent: :delete_all
  has_many   :board_memberships, dependent: :delete_all
  has_many   :user_population_segments, dependent: :destroy
  has_many   :population_segments, through: :user_population_segments

  # Use nullify (default) strategy because these relations are shared by other objects
  # --------------------------------------------------------------------------------------

  has_many   :peer_invitations_as_invitee, class_name: "PeerInvitation", as: :invitee, dependent: :nullify
  has_many   :tiles, foreign_key: :creator_id, dependent: :nullify
  has_many   :tile_completions, as: :user, dependent: :nullify
  has_many   :tile_viewings, as: :user, dependent: :nullify


  # Indirect relationships don't require a deletion strategy
  # --------------------------------------------------------
  has_one    :current_board_membership, -> { where is_current: true }, class_name: "BoardMembership"
  has_one    :demo, through: :current_board_membership
  has_one    :raffle, through: :demo

  has_many   :demos, through: :board_memberships
  has_many   :friends, through: :friendships


  validate :normalized_phone_number_unique, :normalized_new_phone_number_unique, :normalized_new_phone_number_not_taken_by_board
  validate :new_phone_number_has_valid_number_of_digits
  validate :date_of_birth_in_the_past

  validates_uniqueness_of :slug
  validates_uniqueness_of :sms_slug, message: "Sorry, that username is already taken."
  # validates_uniqueness_of :email comes from Clearance
  validates_uniqueness_of :invitation_code, allow_blank: true

  validates_presence_of :name, message: "Please enter a first and last name"
  validates_presence_of :sms_slug, if: :name_present?, message: "Please choose a username"
  validates_presence_of :slug, if: :name_present?

  validates_presence_of :privacy_level
  validates_inclusion_of :privacy_level, in: PRIVACY_LEVELS

  validates_inclusion_of :gender, in: GENDERS, allow_blank: true

  validates_format_of :slug, with: /\A[0-9a-z]+\z/, if: :name_present?
  validates_format_of :sms_slug, with: /\A[0-9a-z]{2,}\z/,
                      message: "Sorry, the username must consist of letters or digits only.",
                      if: :name_present?

  validates_format_of :zip_code, with: /\A\d{5}\z/, allow_blank: true

  validates_length_of :password, minimum: 6, allow_blank: true, message: "must have at least 6 characters", unless: :converting_from_guest

  validates_uniqueness_of :overflow_email, allow_blank: true
  validates_uniqueness_of :email
  validates :email, with: :email_distinct_from_all_overflow_emails
  validates :overflow_email, with: :overflow_email_distinct_from_all_emails
  validates_presence_of :email, if: :converting_from_guest, message: "Please enter a valid email address"
  validates_presence_of :official_email
  validates_with EmailFormatValidator, field: :official_email
  validates_presence_of :email, if: :creating_board, message: "can't be blank"
  validates_with EmailFormatValidator, if: Proc.new { |u| u.invitation_method == :client_admin_invites }

  validates_presence_of :password, if: :converting_from_guest, message: "Please enter a password at least 6 characters long"
  validates_length_of :password, minimum: 6, if: :converting_from_guest, message: "Please enter a password at least 6 characters long"
  validates_presence_of :location_id, if: :must_have_location

  validates_presence_of :password, if: :creating_board, message: "please enter a password at least 6 characters long"


  has_attached_file :avatar,
    {
      styles: {
        thumb: "96x96#"
      },
      default_style: :thumb,
      default_url: ->(attachment) { ActionController::Base.helpers.asset_path(MISSING_AVATAR_PATH) }
    }.merge!(USER_AVATAR_OPTIONS)
  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\Z/

  serialize :characteristics
  accepts_nested_attributes_for :population_segments, reject_if: :all_blank, allow_destroy: true

  before_validation do
    # NOTE: This method is only called when you actually CALL the create method
    # (Not when you ask if the method is valid :on => :create.)
    # creating a new object and testing x.valid? :on => :create does not send us to this function
    set_slugs_based_on_name if name_present? && (self.slug.blank? || self.sms_slug.blank?)
  end

  before_validation do
    downcase_sms_slug
  end

  before_validation(on: :create) do
    self.official_email = email if official_email.blank?
  end

  before_validation do
    if @role.present?
      self.is_client_admin = self.role == "Administrator"
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

  has_alphabetical_column :name

  scope :non_site_admin, -> { where(is_site_admin: false) }

  scope :non_admin, -> { where("users.is_site_admin <> ? AND users.is_client_admin <> ?", true, true) }

  scope :client_admin, -> { where("users.is_site_admin <> ? AND users.is_client_admin = ?", true, true) }

  def self.paid_client_admin
    joins(board_memberships: :demo).where(board_memberships: { is_client_admin: true }, demos: { customer_status_cd: Demo.customer_statuses[:paid] }).uniq
  end

  # TODO: Rewrite this method to use roles architecture and deprecate explore family:
  ## def authorized?(role)
  ##   self.roles.includes?(role)
  ## end
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

  def active_population_segments
    user_population_segments.active.pluck(:population_segment_id)
  end

  def end_user_in_all_boards?
    !is_site_admin && !is_client_admin_in_any_board
  end

  def end_user?
    !is_client_admin && !is_site_admin
  end

  def demo_id
    self.demo.try(:id)
  end

  def organization
    demo.try(:organization)
  end

  def organization_id
    organization.try(:id)
  end

  def email_optional?
    true if phone_number
  end

  def days_since_activated
    accepted_invitation_at.nil? ? 0 : (Date.current - accepted_invitation_at.to_date).to_i
  end

  def role
    @role ||= begin
      if self.is_client_admin || (self.current_board_membership && self.current_board_membership.is_client_admin)
        "Administrator"
      else
        "User"
      end
    end
  end

  def role_in(demo)
    board_membership = self.board_memberships.find_by(demo_id: demo.id)
    if board_membership && board_membership.is_client_admin
      "Administrator"
    else
      "User"
    end
  end
  def update_last_acted_at
    reload if changed? # Let's scrap any dirty changes so we don't get unwanted side-effects
    self.last_acted_at = Time.current
    save!
  end

  def corporate_email
    return email if overflow_email.empty?
    overflow_email
  end

  def email_distinct_from_all_overflow_emails
    return if email.blank? && overflow_email.blank?
    if email.blank? && overflow_email.present?
      self.errors.add(:email, "must have a primary email if you have a secondary email")
    else
      # HRFF: no need to check this unless emails changed
      users_with_your_email = User.where(overflow_email: email).reject { |ff| ff == self }
      self.errors.add(:email, "'#{email}' is already taken") if users_with_your_email.present?
    end
  end

  def overflow_email_distinct_from_all_emails
    return if overflow_email.blank?
    # HRFF: no need to check this unless emails changed
    if User.where(email: overflow_email).reject { |ff| ff == self }.present?
      self.errors.add(:overflow_email, "someone else has your secondary email as their primary email")
    end
    if email == overflow_email
      self.errors.add(:overflow_email, "your primary and secondary emails cannot be the same")
    end
  end

  def date_of_birth_in_the_past
    return unless self.date_of_birth

    unless self.date_of_birth < Date.current
      self.errors.add(:date_of_birth, "must be in the past")
    end
  end

  def her_him
    case self.gender
    when "female"
      "her"
    when "male"
      "him"
    else
      "them"
    end
  end

  def her_his
    case self.gender
    when "female"
      "her"
    when "male"
      "his"
    else
      "their"
    end
  end

  def can_see_activity_of(user)
    return true if self == user
    return true if self.is_site_admin
    case user.privacy_level
    when "everybody"
      return true
    when "connected"
      return true if self.friends_with? user
    end
    false
  end

  def reason_for_privacy
    case self.privacy_level
    when "everybody"
      reason = " allows everyone to see their activity"
    when "connected"
      reason = " only allows connections to see their activity"
    when "nobody"
      reason = " does not allow anyone to see their activity"
    end
    reason
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

    self.class.joins("INNER JOIN friendships on users.id = friendships.user_id").where("friendships.friend_id = ?", self.id)
  end

  def accepted_followers
    followers.where("friendships.state" => "accepted")
  end

  def pending_friends
    friends.where("friendships.state" => "pending")
  end

  def initiated_friends
    friends.where("friendships.state" => "initiated")
  end

  def accepted_friends
    friends.where("friendships.state" => "accepted")
  end

  def displayable_accepted_friends
    accepted_friends.where("users.privacy_level != 'nobody'")
  end

  def friends_with?(other)
    self.relationship_with(other) == "friends"
  end

  def relationship_with(other)
    return "self" if self == other
    from_me = Friendship.where(user_id: self.id, friend_id: other.id).first
    from_me_state = from_me ? from_me.state : nil
    from_them = Friendship.where(friend_id: self.id, user_id: other.id).first
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

  def to_param
    slug
  end

  def generate_new_phone_validation_token
    token = rand(000000..999999).to_s.rjust(6, "0")
    self.new_phone_validation = token
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

  def first_name
    name.split.first.capitalize
  end

  def last_name
    name.split[1..-1].join(" ").try(:titleize)
  end

  def send_new_phone_validation_token
    SmsSenderJob.perform_now(
      to_number: new_phone_number,
      body: new_phone_validation_message
    )
  end

  def confirm_new_phone_number
    self.phone_number = self.new_phone_number
    self.new_phone_number = ""
    self.new_phone_validation = ""
  end

  def new_phone_number_needs_verification?
    new_phone_number.present?
  end

  def new_phone_validation_message
    "Your code to verify this phone with Airbo is #{self.new_phone_validation}."
  end

  def validate_new_phone(entered_validation_code)
    entered_validation_code == self.new_phone_validation
  end

  def cancel_new_phone_number
    self.update_attributes(new_phone_number: "", new_phone_validation: "")
  end

  def reply_email_address
    demo.reply_email_address
  end

  def email_for_vendor
    if is_client_admin
      email
    end
  end

  def mixpanel_distinct_id
    attributes["mixpanel_distinct_id"] || self.id
  end

  def data_for_mixpanel
    {
      distinct_id:           mixpanel_distinct_id,
      id:                    id,
      email:                 email_for_vendor,
      game:                  demo_id,
      users_in_board:        demo.try(:users_count) || 0,
      organization:          organization_id,
      organization_size:     organization.try(:company_size),
      account_creation_date: created_at.try(:to_date),
      joined_game_date:      accepted_invitation_at.try(:to_date),
      user_type:             highest_ranking_user_type,
      board_type:            demo.try(:customer_status_for_mixpanel),
      first_time_user:       false,
      days_since_activated:  days_since_activated
    }
  end

  def mixpanel_data_for_profile
    {
      "$email" => email,
      "$first_name" => first_name,
      "$last_name" => last_name,
      "customer_status" => organization.try(:customer_status),
      "org_size" => organization.try(:company_size),
      "org_name" => organization.try(:name),
      "internal" => organization.try(:internal?)
    }
  end

  def intercom_user_id_with_env
    id.to_s + "-" + Rails.env
  end

  def intercom_data
    {
      user_id: id,
      name: name,
      email: email,
      client_admin: is_client_admin?,
      demo: demo_id,
      organization: organization_id,
      board_type: demo.try(:customer_status_for_mixpanel),
      user_hash: OpenSSL::HMAC.hexdigest("sha256", IntercomRails.config.api_secret.to_s, id.to_s)
    }
  end

  def add_board(board_or_board_id, opts = { is_current: false })
    board_id = board_or_board_id.kind_of?(Demo) ? board_or_board_id.id : board_or_board_id

    return if self.in_board?(board_id)

    board_membership_attrs = { demo_id: board_id }.merge(opts)
    self.board_memberships.create(board_membership_attrs)

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

  def invite(referrer = nil, options = {})
    board = options[:demo_id].present? ? Demo.find(options[:demo_id]) : self.demo

    if referrer && !(options[:ignore_invitation_limit])
      peer_num = self.peer_invitations_as_invitee.where(demo: board).length
      return if peer_num >= PeerInvitation::CUTOFF
    end

    Mailer.invitation(self, referrer, options).deliver_later

    if referrer && !(options[:ignore_invitation_limit])
      PeerInvitation.create!(inviter: referrer, invitee: self, demo: referrer.demo)
    end

    update_attributes(invited: true)
  end

  def invitable?
    email.present?
  end

  def mark_as_claimed(options = {})
    _options = { channel: :web }.merge(options)
    channel = _options[:channel]
    phone_number = _options[:phone_number]
    email = _options[:email]

    update_attribute(:phone_number, PhoneNumber.normalize(phone_number)) if phone_number.present?
    update_attribute(:email, email) if email.present?
    update_attribute(:accepted_invitation_at, Time.current)
    record_claim_in_mixpanel(channel)
  end

  def finish_claim
    add_joining_to_activity_stream
  end

  def join_board
    mark_as_claimed
    finish_claim
  end

  def record_claim_in_mixpanel(channel)
    TrackEvent.ping("claimed account", { channel: channel, source: "Joined via invite" }, self)
  end

  def update_points(point_increment)
    PointIncrementer.call(user: self, increment: point_increment)
  end

  def password_optional?
    true
  end

  def set_invitation_code
    possibly_finished = false

    until (possibly_finished && (self.valid? || self.errors[:invitation_code].empty?))
      possibly_finished = true
      self.invitation_code = Digest::SHA1.hexdigest("--#{Time.current.to_f}--#{self.email}--#{self.name}--")
    end
  end

  def set_invitation_code!
    set_invitation_code
    save!
  end

  def set_explore_token
    self.explore_token = Digest::SHA1.hexdigest("This is the salt for an explore token, how about that--#{Time.current.to_f}--#{self.email}--#{self.name}--")
  end

  def set_explore_token! # useful for backfilling
    set_explore_token
    save!
  end

  def find_same_slug(possible_slug)
    User.where("slug = ? OR sms_slug = ?", possible_slug, possible_slug).order("created_at desc").first
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
    update_attributes(claim_code: claim_code_prefix)
  end

  def generate_unique_claim_code!
    potential_claim_code = nil

    User.transaction do
      suffix = rand(100)

      begin
        suffix += rand(50)
        potential_claim_code = claim_code_prefix + suffix.to_s
      end while User.find_by(claim_code: potential_claim_code)

      self.update_attributes(claim_code: potential_claim_code)
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
      [first_name.first, last_name].join("")
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
          add_board(new_demo, is_client_admin: true, is_current: false)
        else
          return false
        end
      end

      current_board_membership.set_not_current
      set_current_board_membership(new_demo)
    end
  end

  def set_current_board_membership(demo)
    board_membership = board_memberships.find_by(demo_id: demo.id)
    board_membership.set_as_current
  end

  def befriend(other, mixpanel_properties = {})
    friendship = nil
    Friendship.transaction do
      return nil if self.friendships.where(friend_id: other.id).present?
      friendship = self.friendships.create(friend_id: other.id, state: "initiated")
      reciprocal_friendship = other.friendships.create(friend_id: self.id, state: "pending")
      reciprocal_friendship.update_attribute(:request_index, friendship.request_index)
    end

    friendship
  end

  def accept_friendship_from(other)
    Friendship.where(user_id: other.id, friend_id: self.id).first.accept
  end

  def follow_requested_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      default: "OK, you'll be connected with %{followed_user_name}, pending %{her_his} acceptance.",
      followed_user_name: self.name,
      her_his: self.her_his
    )
  end

  def follow_removed_message
    I18n.t(
      "activerecord.models.user.base_follow_message",
      default: "OK, you're no longer connected to %{followed_user_name}.",
      followed_user_name: self.name
    )
  end

  def email_with_name
    "#{name} <#{email}>"
  end

  def email_with_name_via_airbo
    "#{name} via Airbo <#{email}>"
  end

  def mute_for_now
    self.update_attributes(last_muted_at: Time.current)
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

  def profile_page_friends_list
    self.accepted_friends.sort_by { |ff| ff.name.downcase }
  end

  def scoreboard_friends_list_by_tickets
    (self.accepted_friends + [self]).sort_by(&:tickets).reverse
  end

  def scoreboard_friends_list_by_name
    (self.accepted_friends + [self]).sort_by { |ff| ff.name.downcase }
  end

  def has_tiles_tools_subnav?
    is_client_admin || is_site_admin
  end

  def self.send_invitation_if_claimed_sms_user_texts_us_an_email_address(from_phone, text, options = {})
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
    user.invitation_sent_text
  end

  def send_conversion_email
    Mailer.guest_user_converted_to_real_user(self).deliver_later
  end

  def self.referrer_hash(referrer)
    if referrer
      { referrer_id: referrer.id }
    else
      { referrer_id: nil }
    end
  end

  def manually_set_confirmation_token
    update_attributes(confirmation_token: SecureRandom.hex(16))
  end

  def ping(event, properties = {})
    data = data_for_mixpanel.merge(properties)
    TrackEvent.ping(event, data)
  end

  def load_personal_email(in_email)
    return nil unless in_email.try(:is_email_address?)
    return true if email == in_email # do nothing but return true if they try to reload their primary email
    update_attributes(overflow_email: email, email: in_email)
  end

  def credit_game_referrer(referring_user)
    referring_user = User.where(id: referring_user).first
    return unless referring_user

    referrer_act_text = I18n.t("special_command.credit_game_referrer.activity_feed_text", default: "got credit for recruiting %{referred_name}", referred_name: self.name)

    referred_act_text = I18n.t("special_command.credit_game_referrer.referred_activity_feed_text", default: "credited %{referrer_name} for recruiting them", referrer_name: referring_user.name)

    referring_user.acts.create!(
      text: referrer_act_text,
      inherent_points: demo.game_referrer_bonus
    )

    self.acts.create!(
      text: referred_act_text,
      inherent_points: demo.referred_credit_bonus
    )
  end

  def to_ticket_progress_calculator
    TicketProgressCalculator.new(self)
  end

  def self.find_by_either_email(email)
    email = email.strip.downcase
    where("email = ? OR overflow_email = ?", email, email).first
  end

  def is_guest?
    false
  end

  def is_potential_user?
    false
  end

  def highest_ranking_user_type
    return "site admin" if self.is_site_admin
    return "client admin" if current_board_membership && current_board_membership.is_client_admin
    "ordinary user"
  end

  def can_start_over?
    false
  end

  def is_client_admin_in_board(board)
    if board == self.demo
      self.is_client_admin
    else
      board_memberships.find_by(demo_id: board.id).try(:is_client_admin)
    end
  end

  def has_board_in_common_with(other_user)
    board_ids = self.board_memberships.pluck(:demo_id)
    other_user.board_memberships.where(demo_id: board_ids).first.present?
  end

  def is_client_admin_in_any_board
    is_client_admin || is_site_admin || board_memberships.pluck(:is_client_admin).any?
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

  def has_only_board?(board)
    demos == [board]
  end

  def not_in_any_paid_or_trial_boards?
    demos.paid.empty? && demos.free_trial.empty?
  end

  def can_see_raffle_modal?
    true
  end

  def in_multiple_boards?
    demo_ids.length > 1
  end

  def display_get_started_lightbox
    !get_started_lightbox_displayed && demo.tiles.active.present?
  end

  def can_make_tile_suggestions?(_demo = demo)
    demo.everyone_can_make_tile_suggestions || current_board_membership.allowed_to_make_tile_suggestions
  end

  def self.allow_to_make_tile_suggestions(user_ids, demo)
    transaction do
      demo.board_memberships.where(allowed_to_make_tile_suggestions: true).update_all(allowed_to_make_tile_suggestions: false)

      demo.board_memberships.where(user_id: user_ids).update_all(allowed_to_make_tile_suggestions: true)
    end
  end

  def self.allowed_to_suggest_tiles(demo)
    joins(:board_memberships).where(board_memberships: { demo: demo, allowed_to_make_tile_suggestions: true })
  end

  def intros
    # FIXME should use appropriate AR first_or_create idiom
    user_intro || self.create_user_intro # UserIntro.create(user: self)
  end

  private

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
      Friendship.destroy_all(friend_id: self.id)
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

      if self.new_record?
        where_conditions = ["phone_number = ?", normalized_number]
      else
        where_conditions = ["phone_number = ? AND id != ?", normalized_number, self.id]
      end

      if self.class.where(where_conditions).limit(1).present?
        self.errors.add(input, TAKEN_PHONE_NUMBER_ERR_MSG)
      end
    end

    def normalized_new_phone_number_not_taken_by_board
      num = PhoneNumber.normalize(new_phone_number)
      return unless num.present?

      found = Demo.find_by(phone_number: num)
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

    def update_associated_act_privacy_levels
      # See Act for an explanation of why we denormalize privacy_level onto it.
      Act.update_all(privacy_level: self.privacy_level, user_id: self.id) if self.changed.include?("privacy_level")
    end

    def self.claimable_by_first_name_and_claim_code(claim_string)
      normalized_claim_string = claim_string.downcase.gsub(/\s+/, " ").strip
      first_name, claim_code = normalized_claim_string.split
      return nil unless (first_name && claim_code)
      User.where(["name ILIKE ? AND claim_code = ?", first_name.like_escape + "%", claim_code]).first
    end

    def self.add_joining_to_activity_stream(user)
      Act.create!(
        user: user,
        text: "joined!",
        inherent_points: user.demo.seed_points
      )
    end

    def add_joining_to_activity_stream
      self.class.add_joining_to_activity_stream(self)
    end
end
