class Demo < ActiveRecord::Base
  extend NormalizeBoardName

  belongs_to :organization, counter_cache: true
  belongs_to :dependent_board, class_name: "Demo", foreign_key: :dependent_board_id

  has_one  :campaign, dependent: :delete
  has_one :claim_state_machine, dependent: :delete
  has_one :custom_invitation_email, dependent: :delete
  has_one :raffle, dependent: :delete
  has_one :live_raffle, -> { where "status = '#{Raffle::LIVE}' and starts_at <= '#{Time.zone.now.to_time}'"}, class_name: "Raffle"
  has_one :custom_color_palette, dependent: :delete
  has_one :tiles_digest_automator, dependent: :delete

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
  has_many :board_health_reports

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  validates_uniqueness_of :public_slug
  validates_presence_of :public_slug, on: :update

  validates_with EmailFormatValidator, allow_blank: true

  before_validation :unlink_from_organization, if: :unlink
  before_save :normalize_phone_number_if_changed
  after_create :create_public_slug!

  accepts_nested_attributes_for :custom_color_palette
  accepts_nested_attributes_for :organization

  scope :name_order, ->{order("LOWER(name)")}
  scope :health_score_order, -> { order("current_health_score DESC") }

  scope :airbo, -> { joins(:organization).where(organizations: {name: "Airbo"}) }
  scope :active, ->{ where(marked_for_deletion: false) }
  has_alphabetical_column :name

  has_attached_file :logo,
    {
      :styles => {
        :thumb => "x46>"
      },
      default_style: :thumb,
      default_url: ->(attachment) { ActionController::Base.helpers.asset_path("logo.png") },
      keep_old_files: true
    }.merge!(DEMO_LOGO_OPTIONS)
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  has_attached_file :cover_image,
    {
      styles: {
        thumb: "30x30#"
      },
      default_url: ->(attachment) { ActionController::Base.helpers.asset_path("logo.png") },
    }.merge!(DEMO_LOGO_OPTIONS)
  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\Z/

  as_enum :customer_status, free: 0, paid: 1, trial: 2

  attr_accessor :unlink

  def tiles_digest_automator
    super || build_tiles_digest_automator
  end

  def customer_status_for_mixpanel
    customer_status.to_s.capitalize
  end

  def client_admin
    users.where(board_memberships: { is_client_admin: true } )
  end

  def twilio_from_number
    if phone_number.present?
      phone_number
    else
      TWILIO_PHONE_NUMBER
    end
  end

  def self.paid
    where(customer_status_cd: Demo.customer_statuses[:paid])
  end

  def self.free
    where(customer_status_cd: Demo.customer_statuses[:free])
  end

  def self.free_trial
    where(customer_status_cd: Demo.customer_statuses[:trial])
  end

  def self.paid_or_free_trial
    where("customer_status_cd = ? OR customer_status_cd = ?", Demo.customer_statuses[:paid], Demo.customer_statuses[:trial])
  end

  def self.unmatched
    where(organization_id: nil)
  end

  def latest_health_report
    board_health_reports.where(period_cd: BoardHealthReport.periods[:week]).order(:created_at).last
  end

  def internal?
    organization.try(:internal)
  end

  def organization_name
   organization.present? ? organization.name : "Unattached To Any Organization"
  end

  def company_size
    organization.try(:company_size)
  end

  def name_as_noun
    if name =~ /(board)\z/i
      name
    else
      name + " board"
    end
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

  def tile_engagement_report
    BoardHealthReport.tile_engagement_report(board: self)
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

  def digest_tiles(cutoff_time = self.tile_digest_email_sent_at)
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

  def welcome_message(user=nil)
    custom_message(
      :custom_welcome_message,
      "You've joined the %{name} game! @{reply here}",
      user,
      :name => [:demo, :name],
      :unique_id    => [:sms_slug]
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

  def self.number_not_found_response(receiving_number)
    demo = self.where(:phone_number => receiving_number).first
    demo ? demo.number_not_found_response : default_number_not_found_response
  end

  def self.default_number_not_found_response
    "I can't find your number in my records. Did you claim your account yet? If not, text your first initial and last name (if you are John Smith, text \"jsmith\")."
  end

  # TODO: This isn't great but a work around until we sort out referencing BMs vs Users for things like tickets.
  def flush_all_user_tickets
    guest_users.update_all("tickets = 0, ticket_threshold_base = points")
    board_memberships.update_all("tickets = 0, ticket_threshold_base = points")
    users.where(board_memberships: { is_current: true }).update_all("tickets = 0, ticket_threshold_base = points")
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
      while (demo = Demo.find_by(public_slug: candidate_slug)).present?
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

  def has_normal_users?
    (self.users.non_admin.count > 0) || (self.guest_users.count > 0)
  end

  def self.name_like(name)
    where("name ILIKE ?", normalize_board_name(name))
  end

  def intro_message
    if persistent_message.present?
      persistent_message.html_safe
    else
      Demo.default_persistent_message
    end
  end

  def self.default_persistent_message
    "Airbo is an engaging microsite for employee communication. Get started by clicking on a Tile. Answer questions to earn points."
  end

  def set_for_delete
    update_column(:marked_for_deletion, true)
    BoardDeletionJob.new(self.id).perform
  end

  def name_and_org_name
    "#{name}, #{organization.try(:name)}"
  end

  def self.list_with_org_name_and_user_count
    demos = Demo.arel_table
    bms = BoardMembership.arel_table
    orgs = Organization.arel_table

    x = Demo.select(
      [orgs[:name].as("org_name"), demos[:id], demos[:name], demos[:dependent_board_id], bms[:user_id].count.as('user_count')]
    ).joins(
      bms.join(orgs).on( demos[:organization_id].eq(orgs[:id]))
      .join(bms,Arel::Nodes::OuterJoin).on( bms[:demo_id].eq(demos[:id]))
      .join_sources
    ).order(
      Arel::Nodes::NamedFunction.new('LOWER', [demos[:name]])
    )

    x.group(orgs[:name], demos[:id], demos[:name], demos[:dependent_board_id])
  end

  def data_for_dom
    {
      id: id,
      name: name,
      dependent_board_enabled: dependent_board_enabled
    }.to_json
  end

  def data_for_mixpanel(user:)
    {
      distinct_id:           user.mixpanel_distinct_id,
      user_id:               user.id,
      user_email:            user.email_for_vendor,
      game:                  id,
      users_in_board:        users_count || 0,
      organization:          organization_id,
      organization_size:     company_size,
      account_creation_date: user.created_at.to_date,
      user_type:             user.highest_ranking_user_type,
      board_type:            customer_status_for_mixpanel,
    }
  end

  def set_tile_email_draft(params)
    rdb["tile_email_draft"].set(params.to_json)
  end

  def clear_tile_email_draft
    rdb["tile_email_draft"].del
  end

  def get_tile_email_draft
    draft = rdb["tile_email_draft"].get

    if draft.present?
      JSON.parse(draft).symbolize_keys
    end
  end

  private

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

    def normalize_phone_number_if_changed
      return unless self.changed.include?('phone_number')
      self.phone_number = PhoneNumber.normalize(self.phone_number)
    end

    def self.add_odd_row_placeholders!(tiles, row_size = 4)
      odd_row_length = tiles.length % row_size
      placeholders_to_add = odd_row_length == 0 ? 0 : row_size - odd_row_length

      placeholders_to_add.times { tiles << TileOddRowPlaceholder.new }
      tiles
    end

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
