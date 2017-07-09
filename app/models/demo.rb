class Demo < ActiveRecord::Base
  extend NormalizeBoardName
  include Assets::Normalizer # normalize filename of paperclip attachment
  extend ValidImageMimeTypes

  JOIN_TYPES = %w(pre-populated self-inviting public).freeze

  belongs_to :organization, counter_cache: true
  belongs_to :dependent_board, class_name: "Demo", foreign_key: :dependent_board_id

  has_one  :campaign, dependent: :delete
  has_one  :topic_board, dependent: :delete
  has_one  :onboarding, dependent: :delete
  has_one :claim_state_machine, dependent: :delete
  has_one :custom_invitation_email, dependent: :delete
  has_one :raffle, dependent: :delete
  has_one :live_raffle, class_name: "Raffle", conditions: "status = '#{Raffle::LIVE}' and starts_at <= '#{Time.zone.now.to_time}'"
  has_one :custom_color_palette, dependent: :delete

  # NOTE m_tiles is an unfortunate hack to compensate for shitty code implementation of MultipleChoiceTile
  has_many :m_tiles, :dependent => :destroy, class_name: 'MultipleChoiceTile', dependent: :delete_all
  has_many :board_memberships, dependent: :delete_all
  has_many :tiles, :dependent => :delete_all

  has_many :guest_users, dependent: :delete_all
  has_many :potential_users, dependent: :delete_all
  has_many :peer_invitations, dependent: :delete_all
  has_many :characteristics, :dependent => :delete_all
  has_many :push_messages, dependent: :delete_all
  has_many :acts, dependent: :delete_all
  has_many :tiles_digests, dependent: :delete_all
  has_many :follow_up_digest_emails, through: :tiles_digests

  has_many :locations, :dependent => :destroy
  has_many :users, through: :board_memberships
  has_many :tile_completions, through: :tiles
  has_many :tile_viewings, through: :tiles


  validates_inclusion_of :join_type, :in => JOIN_TYPES

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  validates_uniqueness_of :public_slug
  validates_presence_of :public_slug, on: :update

  validate :ticket_fields_all_set, :if => :uses_tickets

  validates_with EmailFormatValidator, allow_blank: true

  before_validation :unlink_from_organization, if: :unlink
  before_save :normalize_phone_number_if_changed
  after_create :create_public_slug!

  accepts_nested_attributes_for :custom_color_palette
  accepts_nested_attributes_for :organization

  scope :name_order, ->{order("LOWER(name)")}
  scope :airbo, -> { joins(:organization).where(organization: {name: "Airbo"}) }
  scope :active, ->{where(marked_for_deletion: false)}
  has_alphabetical_column :name

  has_attached_file :logo,
    {
      :styles => {:thumb => ["x46>", :png]},
      :default_style => :thumb,
      :default_url => "/assets/logo.png",
    }.merge!(DEMO_LOGO_OPTIONS)

  has_attached_file :cover_image,
    {
      :styles => {:thumb => ["30x30#", :png]},
      :default_url => "/assets/logo.png",
    }.merge!(DEMO_LOGO_OPTIONS)

  validates_attachment_content_type :logo, content_type: valid_image_mime_types, message: invalid_mime_type_error

  scope :campaigns, -> { joins(:topic_board).where(topic_board: { is_library: true } ) }

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

  attr_accessor :unlink

  ###ROLLOUT
    def has_end_user_search
      rdb[:has_end_user_search].get == "true"
    end

    def has_end_user_search=(bool)
      rdb[:has_end_user_search].set(bool)
    end
  ###

  def client_admin
    users.joins(:board_memberships).where(board_memberships: { is_client_admin: true, demo_id: self.id } )
  end

  def self.paid
    where(is_paid: true)
  end

  def self.unmatched
    where(organization_id: nil)
  end

  def self.list
    demos = Demo.arel_table
    bms = BoardMembership.arel_table
    orgs = Organization.arel_table

    x = Demo.select(
      [orgs[:name].as("org_name"), demos[:id], demos[:name], demos[:dependent_board_id],
       demos[:is_paid], bms[:user_id].count.as('user_count')]
    ).joins(
      bms.join(orgs).on( demos[:organization_id].eq(orgs[:id]))
      .join(bms,Arel::Nodes::OuterJoin).on( bms[:demo_id].eq(demos[:id]))
      .join_sources
    ).order(
      Arel::Nodes::NamedFunction.new('LOWER', [demos[:name]])
    )

    x.group(orgs[:name], demos[:id], demos[:name], demos[:dependent_board_id],
            demos[:is_paid])
  end

  def users_for_digest
    self.users.joins(:board_memberships).where(board_memberships: { demo_id: self.id, digest_muted: false })
  end

  def claimed_users_for_digest
    users_for_digest.where("board_memberships.joined_board_at IS NOT NULL")
  end

  def organization_name
   organization.present? ? organization.name : "Unattached To Any Organization"
  end

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

  def suggested_tiles
    tiles.suggested
  end

  def archive_tiles_with_placeholders tile_set=archive_tiles
    self.class.add_odd_row_placeholders! tile_set
  end

  def active_tiles_with_placeholders tile_set=active_tiles
    self.class.add_odd_row_placeholders! tile_set
  end

  def draft_tiles_with_placeholders tile_set=draft_tiles
    self.class.add_odd_row_placeholders! tile_set, 6
  end

  def suggested_tiles_with_placeholders tile_set=suggested_tiles
    self.class.add_odd_row_placeholders! tile_set
  end

  def self.add_placeholders tiles
    add_odd_row_placeholders! tiles
  end

  def draft_tiles
    tiles.draft
  end


  def  bracket tile
    arr = by_status_and_position_of_tile tile.status
    [prev_in_group(arr, tile.id), next_in_group(arr, tile.id)]
  end


  #NOTE technically position should never be nil so the use of compact should
  #not be necessary here
  def next_draft_tile_position
    (draft_tiles.map(&:position).compact.max ||0) + 1
  end

  def digest_tiles(cutoff_time=self.tile_digest_email_sent_at)
    tiles.digest(self, cutoff_time)
  end

  def claimed_users(excluded_uids: [])
    users.claimed_on_board_membership(self.id, excluded_uids)
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
    email_name, email_address = if self.email.present?
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
    claimed_users.non_site_admin.count
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

  def organization_name
    organization.try(:name)
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

  # TODO: This isn't great but a work around until we sort out referencing BMs vs Users for things like tickets.
  def flush_all_user_tickets
    guest_users.update_all("tickets = 0, ticket_threshold_base = points")
    board_memberships.update_all("tickets = 0, ticket_threshold_base = points")
    users.joins(:board_memberships).where(board_memberships: { demo_id: id, is_current: true }).update_all("tickets = 0, ticket_threshold_base = points")
  end

  # TODO: Deprecate below
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
  #

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

  def users_that_allowed_to_suggest_tiles
    User.allowed_to_suggest_tiles self
  end

  def self.public_board_by_public_slug(public_slug)
    self.where(public_slug: public_slug).public.first
  end

  def self.public_board_by_id(id)
    self.where(id: id).public.first
  end

	def non_activated? # CUT?  #TODO find a way to do this without doing a query every time.
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

  def company_size(user_count)
    if user_count < 1000
      "small"
    elsif user_count < 5000
      "medium"
    else
      "enterprise"
    end
  end

  def set_for_delete
    update_column(:marked_for_deletion, true)
    BoardDeletionJob.new(self.id).perform
  end

  def name_and_org_name
    "#{name}, #{organization.try(:name)}"
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

  def self.add_odd_row_placeholders!(tiles, row_size = 4)
    odd_row_length = tiles.length % row_size
    placeholders_to_add = odd_row_length == 0 ? 0 : row_size - odd_row_length

    placeholders_to_add.times { tiles << TileOddRowPlaceholder.new }
    tiles
  end

  private

  def unlink_from_organization
      self.organization_id=nil
  end

  def next_in_group array, id
   tile_offset(array, id, 1) || array.first
  end

  def prev_in_group array, id
   tile_offset(array, id, -1) || array.last
  end

  def tile_offset array, id, offset
    array[array.index(id) + offset]
  end

  def by_status_and_position_of_tile status
    tiles.where(status: status).ordered_by_position.map(&:id)
  end
end
