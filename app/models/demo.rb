class Demo < ActiveRecord::Base
  extend NormalizeBoardName
  include Assets::Normalizer # normalize filename of paperclip attachment
  extend ValidImageMimeTypes

  JOIN_TYPES = %w(pre-populated self-inviting public).freeze

  has_many :guest_users
  has_many :parent_board_users
  has_many :board_memberships, dependent: :destroy
  has_many :users, through: :board_memberships
  has_many :acts
  has_many :tiles, :dependent => :destroy
  has_many :locations, :dependent => :destroy
  has_many :characteristics, :dependent => :destroy
  has_many :peer_invitations
  has_many :push_messages

  has_many :tile_completions, through: :tiles 
  has_many :tile_viewings, through: :tiles

  has_many :follow_up_digest_emails

  has_one :claim_state_machine
  has_one :custom_invitation_email
  has_one :raffle

  validates_inclusion_of :join_type, :in => JOIN_TYPES

  validates_uniqueness_of :name
  validates_presence_of :name

  validates_uniqueness_of :public_slug
  validates_presence_of :public_slug, on: :update

  validate :ticket_fields_all_set, :if => :uses_tickets

  validates :email, uniqueness: { case_sensitive: false, allow_blank: true }
  validates_with EmailFormatValidator, allow_blank: true

  before_save :normalize_phone_number_if_changed
  after_create :create_public_slug!

  has_alphabetical_column :name

  has_attached_file :logo,
    {
      :styles => {:thumb => ["x46>", :png]},
      :default_style => :thumb,
      :default_url => "/assets/logo.png",
      :bucket => S3_LOGO_BUCKET
    }.merge(DEMO_LOGO_OPTIONS)

  validates_attachment_content_type :logo, content_type: valid_image_mime_types, message: invalid_mime_type_error

  # We go through this rigamarole since we can move a user from one demo to
  # another, and usually we will only be concerned with acts belonging to the
  # current demo. The :conditions option on has_many isn't quite flexible
  # enough to specify this.
  #
  # Meanwhile we have a corresponding before_create callback in Act to make
  # sure the demo_id there gets set appropriately.
  module ActsWithCurrentDemoChecked
    def acts
      super.in_demo(self)
    end
  end
  include ActsWithCurrentDemoChecked
  
  def activate_tiles_if_showtime
    tiles.activate_if_showtime
  end

  def archive_tiles_if_curtain_call
    tiles.archive_if_curtain_call
  end

  def active_tiles
    tiles.active
  end

  def archive_tiles
    tiles.archive
  end

  def archive_tiles_with_creation_placeholder
    [TileCreationPlaceholder.new] + archive_tiles
  end

  def archive_tiles_with_placeholders
    add_odd_row_placeholders! archive_tiles
  end

  def archive_tiles_with_placeholders_and_pagination(page)
    add_odd_row_placeholders! archive_tiles.page(page).per(12)
  end

  def active_tiles_with_placeholders
    add_odd_row_placeholders! active_tiles
  end

  def draft_tiles_with_placeholders
    add_odd_row_placeholders! draft_tiles_with_creation_placeholder
  end

  def draft_tiles_with_creation_placeholder
    [TileCreationPlaceholder.new] + draft_tiles
  end

  def add_placeholders tiles
    add_odd_row_placeholders! tiles
  end

  def draft_tiles
    tiles.draft
  end

  def digest_tiles(cutoff_time=self.tile_digest_email_sent_at)
    tiles.digest(self, cutoff_time)
  end

  # Note that 'unclaimed_users_also_get_digest' is a param passed to this method, not the demo's attribute of the same name
  def users_for_digest(unclaimed_users_also_get_digest)
    unclaimed_users_also_get_digest ? users : users.claimed
  end

  # Returns the number of users who have completed each of the tiles for this demo in a hash
  # keyed by tile_id, e.g. {12 => 565, 13 => 222, 17 => 666, 21 => 2} (Apparently #21 sucked )
  def num_tile_completions
    unless @_num_tile_completions
      @_num_tile_completions = tile_completions.group(:tile_id).count
    end

    @_num_tile_completions
  end

  def example_tooltip_or_default
    default = "went for a walk"
    example_tooltip.blank? ? default : example_tooltip
  end
  
  def welcome_message(user=nil)
    custom_message(
      :custom_welcome_message,
      "You've joined the %{name} game! @{reply here}",
      user,
      :name => [:demo, :name],
      :unique_id    => [:sms_slug]
    )
  end

  def prize_message(user = nil)
    custom_message(
      :prize,
      "Sorry, no physical prizes this time. This one's just for the joy of the contest."
    )
  end

  def help_response(user = nil)
    custom_message(
      :help_message,
      "Text:\nRULES for command list\nPRIZES for prizes\nSUPPORT for help from the help desk"
    )
  end

  def game_over_response
    custom_message(
      :act_too_late_message,
      "Thanks for participating. Your administrator has disabled this board. If you'd like more information e-mailed to you, please text INFO."
    )
  end

  def reply_email_name
    if custom_reply_email_name.present?
      custom_reply_email_name
    else
      name
    end
  end

  def reply_email_address(include_name = true)
    email_name, email_address = if self.email
                    [self.reply_email_name, self.email]
                  else
                    ['Airbo', 'play@ourairbo.com']
                  end

    if include_name
      "#{email_name} <#{email_address}>"
    else
      email_address
    end
  end

  def claim_state_machine_with_default
    claim_state_machine_without_default || ClaimStateMachine.default_claim_state_machine(self)
  end

  def claimed_user_count
    users.claimed.where(is_site_admin: false).count
  end

  def claimed_user_with_phone_fraction
    _claimed_user_count = claimed_user_count
    if _claimed_user_count > 0
      users.claimed.with_phone_number.count.to_f / claimed_user_count
    else
      0.0
    end
  end

  def claimed_user_with_peer_invitation_fraction
    _claimed_user_count = claimed_user_count
    if _claimed_user_count > 0
      users.claimed.with_game_referrer.count.to_f / claimed_user_count
    else
      0.0
    end
  end

  alias_method_chain :claim_state_machine, :default

  def number_not_found_response
    custom_message(
      :unrecognized_user_message,
      self.class.default_number_not_found_response
    )
  end

  def already_claimed_message(user)
    custom_message(
      :custom_already_claimed_message,
      "You've already claimed your account, and have %{points} pts. If you're trying to credit another user, ask them to check their username with the MYID command.",
      user,
      :points => [:points]
    )
  end

  def support_reply
    custom_message(
      :custom_support_reply,
      "Got it. We'll have someone email you shortly. Tech support is open 9 AM to 6 PM ET. If it's outside those hours, we'll follow-up first thing when we open."
    )
  end

  def location_breakdown
    {}.tap do |breakdown|
      self.locations.each {|location| breakdown[location] = location.users.count}
    end
  end
  
  def self.number_not_found_response(receiving_number)
    demo = self.where(:phone_number => receiving_number).first
    demo ? demo.number_not_found_response : default_number_not_found_response
  end

  def self.default_number_not_found_response
    "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."
  end

  def name_with_sponsor
    if sponsor
      "#{name} at #{sponsor}"
    else
      name
    end
  end      
  
  def print_pending_friendships
    total_friendships = Friendship.where(:user_id => user_ids).count / 2
    number_accepted = Friendship.where(:user_id => user_ids, :state => "accepted").count / 2
    percent = 100.0 * number_accepted / total_friendships
    "#{name} has #{total_friendships} initiated connections, #{number_accepted} of which have been accepted (#{percent}%)"
  end
  
  def ticket_spread
    return nil unless self.uses_tickets

    self.maximum_ticket_award - self.minimum_ticket_award
  end

  def flush_all_user_tickets
    GuestUser.delay.update_all("tickets = 0, ticket_threshold_base = points", {demo_id: self.id})
    users.each do |user|
      user.delay.flush_tickets_in_board(id)
    end
  end

  def find_raffle_winner(eligible_user_ids, ticket_maximum)
    eligibles = users.with_some_tickets.order("tickets ASC")

    if eligible_user_ids
      eligibles = eligibles.where(:id => eligible_user_ids)
    end

    return nil if eligibles.empty?

    chances = []
    eligibles.each do |user|
      if ticket_maximum
        [user.tickets, ticket_maximum].min.times {chances << user}
      else
        user.tickets.times {chances << user}
      end
    end

    index = rand(chances.length)
    chances[index]
  end

  def invitation_email
    self.custom_invitation_email || CustomInvitationEmail.new(demo: self)
  end

  def uses_tickets
    # We may allow demos in the future that don't use tickets, for now we just clamp this to...
    true
  end

  def create_public_slug!
    slug_prefix = name.downcase.gsub(/[^a-z0-9 ]/, '').gsub(/ +/, '-').gsub(/-board$/, '')
    candidate_slug = slug_prefix
    offset = 2 # in case of a collision on the slug "foobar", we'll try "foobar-2" first

    Demo.transaction do
      while (demo = Demo.find_by_public_slug(candidate_slug)).present?
        break if demo.id == self.id
        candidate_slug = slug_prefix + "-" + offset.to_s
        offset += 1
      end
      update_attributes(public_slug: candidate_slug)
    end
  end


  def self.public
    where(is_public: true)
  end

  def self.public_board_by_public_slug(public_slug)
    self.where(public_slug: public_slug).public.first
  end

  def self.public_board_by_id(id)
    self.where(id: id).public.first
  end

  def non_activated? # CUT?
    self.tiles.active.empty? && self.tiles.where('activated_at IS NOT NULL').count < 1
  end
  
  def has_normal_users?
    (self.users.non_admin.count > 0) || (self.guest_users.count > 0)
  end

  def self.name_like(name)
    where("name ILIKE ?", normalize_board_name(name))
  end

  def self.default_persistent_message
    "Airbo is an interactive communication tool. Get started by clicking on a tile. Interact and answer questions to earn points."
  end

  protected



  def unless_within(cutoff_time, last_done_time)
    if last_done_time.nil? || cutoff_time >= last_done_time
      Demo.transaction do
        yield
      end
    end
  end

  def custom_message(custom_message_method_name, default_message, user = nil, method_chains_for_interpolation = {})
    custom_message_text = self.send(custom_message_method_name)

    semi_interpolated_text = if custom_message_text.blank?
      default_message
    else
      custom_message_text
    end

    if user
      interpolations = {}
      method_chains_for_interpolation.each do |key, method_chain|
        interpolations[key] = method_chain.inject(user) {|result, method_name| result.try(method_name)}
      end
      I18n.interpolate(semi_interpolated_text, interpolations)
    else
      semi_interpolated_text
    end
  end

  def ticket_fields_all_set
    unless ticket_threshold.present?
      self.errors.add(:ticket_threshold, "must be set if you want to use gold coins on this demo")
    end
  end

  def normalize_phone_number_if_changed
    return unless self.changed.include?('phone_number')
    self.phone_number = PhoneNumber.normalize(self.phone_number)
  end

  def resegment_everyone
    self.user_ids.each {|user_id| User.find(user_id).send(:schedule_segmentation_update, true)}
  end

  def add_odd_row_placeholders!(tiles)
    odd_row_length = tiles.length % 4
    placeholders_to_add = odd_row_length == 0 ? 0 : 4 - odd_row_length

    placeholders_to_add.times { tiles << TileOddRowPlaceholder.new }
    tiles
  end


   
end
