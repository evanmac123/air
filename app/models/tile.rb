class Tile < ActiveRecord::Base
  include Concerns::TileImageable

  ACTIVE  = 'active'.freeze
  ARCHIVE = 'archive'.freeze
  DRAFT   = 'draft'.freeze
  USER_DRAFT = 'user_draft'.freeze
  USER_SUBMITTED   = 'user_submitted'.freeze
  IGNORED = 'ignored'.freeze

  STATUS  = [ACTIVE, ARCHIVE, DRAFT, USER_DRAFT, USER_SUBMITTED, IGNORED].freeze
  # Question Types
  ACTION = 'Action'.freeze
  QUIZ   = 'Quiz'.freeze
  SURVEY = 'Survey'.freeze
  # Question Subtypes
  TAKE_ACTION           = "Take Action".parameterize("_").freeze
  READ_TILE             = "Read Tile".parameterize("_").freeze
  READ_ARTICLE          = "Read Article".parameterize("_").freeze
  SHARE_ON_SOCIAL_MEDIA = "Share On Social Media".parameterize("_").freeze
  VISIT_WEB_SITE        = "Visit Web Site".parameterize("_").freeze
  WATCH_VIDEO           = "Watch Video".parameterize("_").freeze
  CUSTOM                = "Custom...".parameterize("_").freeze
  TRUE_FALSE            = "True / False".parameterize("_").freeze
  MULTIPLE_CHOICE       = "Multiple Choice".parameterize("_").freeze
  RSVP_TO_EVENT         = "RSVP to event".parameterize("_").freeze
  INVITE_SPOUSE         = "Invite Spouse".parameterize("_").freeze


  belongs_to :demo
  belongs_to :creator, class_name: 'User'
  belongs_to :original_creator, class_name: 'User'

  has_many :tile_completions, :dependent => :destroy
  has_many :completed_tiles, source: :tile, through: :tile_completions
  has_many :tile_taggings, dependent: :destroy
  has_many :tile_tags, through: :tile_taggings
  has_many :user_tile_copies, dependent: :destroy
  has_many :user_tile_likes, dependent: :destroy
  has_many :tile_viewings, dependent: :destroy
  has_many :user_viewers, through: :tile_viewings, source: :user, source_type: 'User'
  has_many :guest_user_viewers, through: :tile_viewings, source: :user, source_type: 'GuestUser'

  has_alphabetical_column :headline

  before_validation :sanitize_supporting_content
  before_validation :sanitize_embed_video
  before_validation :set_image_processing, if: :image_changed?
  validates_presence_of :headline, :allow_blank => false, :message => "headline can't be blank"
  validates_presence_of :supporting_content, :allow_blank => false, :message => "supporting content can't be blank", :on => :client_admin
  validates_presence_of :question, :allow_blank => false, :message => "question can't be blank", :on => :client_admin
  validates_inclusion_of :status, in: STATUS

  #FIXME should be use a constant instead of magic numbers here.
  validates_length_of :headline, maximum: 75, message: "headline is too long (maximum is 75 characters)"
  validates_with RawTextLengthInHTMLFieldValidator, field: :supporting_content, maximum: 700, message: "supporting content is too long (maximum is 600 characters)"

  validates_presence_of :remote_media_url, message: "image is missing" , if: :requires_remote_media_url

  before_create :set_on_first_position
  before_save :ensure_protocol_on_link_address, :handle_status_change
  before_save :set_image_credit_to_blank_if_default
  after_save :process_image, if: :image_changed?
  before_post_process :no_post_process_on_copy

  STATUS.each do |status_name|
    scope status_name.to_sym, -> { where(status: status_name).ordered_by_position }
  end
  scope :after_start_time, -> { where("start_time < ? OR start_time IS NULL", Time.now) }
  scope :before_end_time, -> { where("end_time > ? OR end_time IS NULL", Time.now) }
  scope :after_start_time_and_before_end_time, -> { after_start_time.before_end_time }

  #FIXME suggested and status are not the same thing!

  scope :suggested, -> do
    where{ (status == USER_SUBMITTED) | (status == IGNORED) }
      .order{ status.desc } # first submitted then ignored
      .ordered_by_position
  end
  scope :digest, ->(demo, cutoff_time) { cutoff_time.nil? ? active : active.where("activated_at > ?", cutoff_time) }
  scope :viewable_in_public, -> { where(is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE]) }
  scope :copyable, -> { viewable_in_public.where(is_copyable: true) }
  scope :tagged_with, ->(tag_id) do
    if tag_id.present?
      tagged_tile_ids = TileTagging.where(tile_tag_id: tag_id).pluck(:tile_id)
      where(id: tagged_tile_ids)
    end
  end
  scope :ordered_for_explore, -> { order("explore_page_priority DESC NULLS LAST").order("id DESC") }
  scope :ordered_by_position, -> { order "position DESC" }

  alias_attribute :copy_count, :user_tile_copies_count
  alias_attribute :like_count, :user_tile_likes_count
  alias_attribute :total_views, :total_viewings_count
  alias_attribute :unique_views, :unique_viewings_count
  alias_attribute :interactions, :tile_completions_count

  # Custom Attribute Setter: ensure that setting/updating the 'status' updates the corresponding time-stamp

  STATUS.each do |status_name|
    define_method(status_name + "?") do
      self.status == status_name
    end
  end

  def status=(new_status)
    case new_status
    when ACTIVE  then
      if !already_activated
        self.activated_at = Time.now
      end
    when ARCHIVE then self.archived_at  = Time.now
    end
    write_attribute(:status, new_status)
  end

  def points= p
    write_attribute(:points, p.to_i)
  end

  def image_credit= text
    write_attribute(:image_credit, text.try(:strip))
  end

  def suggested?
    ignored? || user_submitted?
  end

  def has_client_admin_status?
    active? || archive? || draft?
  end

  def is_survey?
    question_type == SURVEY || (question_type.nil? && correct_answer_index == -1)
  end

  def is_quiz?
    question_type == QUIZ || (question_type.nil? && correct_answer_index > 0)
  end

  def is_action?
    question_type == ACTION
  end

  def is_invite_spouse?
    question_subtype == INVITE_SPOUSE
  end

  def survey_chart
    SurveyChart.new(self).build
  end

  def to_form_builder
    TileBuilderForm.new(demo, tile: self)
  end

  def is_placeholder?
    false
  end

  def copy_inside_demo new_demo, copying_user
    CopyTile.new(new_demo, copying_user).copy_tile self, false
  end

  def copy_to_new_demo(new_demo, copying_user)
    CopyTile.new(new_demo, copying_user).copy_tile self
  end

  def update_status status
    self.status = status
    self.position = find_new_first_position
    self.save
  end

  def find_new_first_position
    Tile.where(demo: self.demo, status: self.status).maximum(:position).to_i + 1
  end

  def viewed_by user
    TileViewing.add(self, user) if user
  end

  def self.displayable_categorized_to_user(user, maximum_tiles)
    DisplayCategorizedTiles.new(user, maximum_tiles).displayable_categorized_tiles
  end

  def self.satisfiable_to_user(user, curr_demo=nil)
    board = curr_demo || user.demo.id
    tiles_due_in_demo = after_start_time_and_before_end_time.where(demo_id: board, status: ACTIVE)
    ids_completed = user.tile_completions.map(&:tile_id)
    satisfiable_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    satisfiable_tiles.sort_by(&:position).reverse
  end

  def self.next_public_tile tile_id, offset, tag_id
    tiles = Tile.viewable_in_public.ordered_for_explore.tagged_with(tag_id)
    tile = Tile.viewable_in_public.where(id: tile_id).first
    next_tile = tiles[tiles.index(tile) + offset] || tiles.first # if index out of length
    next_tile || tile # i.e. we have only one tile so next tile is nil
  end

  def self.next_manage_tile tile, offset, carousel = true
    tiles = where(status: tile.status, demo: tile.demo).ordered_by_position
    first_tile = carousel ? tiles.first : nil
    tiles[tiles.index(tile) + offset] || first_tile
  end

  # ------------------------------------------------------------------------------------------------------------------
  # These methods are for synchronizing a tile's start_time/end_time with its ACTIVE/ARCHIVE status.
  # (Tile has a custom attribute writer that updates the activated_at/archived_at along with the ACTIVE/ARCHIVE status)
  #
  # For 'activate_if_showtime' you need to set the 'start_time' to 'nil' because of the following scenario:
  # On Sunday, one of the Ks creates a tile with a 'start_time' of Monday. This is not uncommon as the Ks tend to work 80 hours per week.
  # Tuesday rolls around and the client-admin fires up the Tile Manager (which calls this method) => tile becomes active.
  # On Wednesday a client-admin decides to archive this tile.
  # On Thursday, the same logic would once again activate this tile because (a) it is archived -and- (b) Thursday is > Monday (its 'start_time').
  #
  # And the fun doesn't stop there: a similar scenario (and solution) exists for automatically archiving tiles!
  # ------------------------------------------------------------------------------------------------------------------
  def self.activate_if_showtime
    showtime = archive.where("start_time IS NOT NULL AND ? > start_time", Time.now)
    showtime.each { |tile| tile.update_attributes status: ACTIVE, start_time: nil }
  end

  def self.archive_if_curtain_call
    curtain_call = active.where("end_time IS NOT NULL AND ? > end_time", Time.now)
    curtain_call.each { |tile| tile.update_attributes status: ARCHIVE, end_time: nil }
  end
  # ------------------------------------------------------------------------------------------------------------------

  def self.bulk_complete(demo_id, tile_id, emails)
    Delayed::Job.enqueue TileBulkCompletionJob.new(demo_id, tile_id, emails)
  end

  def self.find_additional_tiles_for_manage_section(status_name, presented_ids, tile_demo_id)
    FindAdditionalTilesForManageSection.new(status_name, presented_ids, tile_demo_id).find
  end

  def self.insert_tile_between left_tile_id, tile_id, right_tile_id, new_status = nil
    InsertTileBetweenTiles.new(left_tile_id, tile_id, right_tile_id, new_status).insert!
  end

  def self.reorder_explore_page_tiles! tile_ids
    ReorderExplorePageTiles.new(tile_ids).reorder
  end

  def right_tile
    self_position = self.position
    Tile.where(demo: self.demo)
      .where(status: self.status)
      .where{position < self_position}
      .ordered_by_position.first
  end

  def left_tile
    self_position = self.position
    Tile.where(demo: self.demo)
      .where(status: self.status)
      .where{position > self_position}
      .order("position ASC").first
  end

  def is_cloned?
    @cloned || false
  end

  def is_cloned= val
    @cloned = val
  end

  def custom_supporting_content_class
    use_old_line_break_css? ? 'old_line_break_css' : ''
  end

  def show_external_link?
    use_old_line_break_css
  end

  protected

  def set_on_first_position
    self.position = find_new_first_position
  end

  def ensure_protocol_on_link_address
    return unless link_address_changed?
    return if link_address =~ %r{^(http://|https://)}i
    return if link_address.blank?

    self[:link_address] = "http://#{link_address}"
  end

  def no_post_process_on_copy
    !(@making_copy)
  end

  private

  def already_activated
    status == ACTIVE && activated_at.present?
  end

  def sanitize_supporting_content
    self.supporting_content = Sanitize.fragment(
      strip_content,
      elements: [
        'ul', 'ol', 'li',
        'b', 'strong', 'i', 'em', 'u',
        'span', 'div', 'p',
        'br', 'a'
      ],
      attributes: { 'a' => ['href', 'target'] }
    ).strip
  end

  def sanitize_embed_video
    self.embed_video = Sanitize.fragment(
      (self.embed_video.try(:strip) || ""),
      elements: ['iframe'],
      attributes: { 'iframe' => ['src', 'width', 'height', 'allowfullscreen', 'webkitallowfullscreen', 'mozAllowFullScreen', 'frameborder', 'allowtransparency', 'frameborder', 'scrolling', 'class', 'oallowfullscreen'] }
    ).strip
  end

  def strip_content
    supporting_content.try(:strip) || ""
  end


  def set_image_credit_to_blank_if_default
    self.image_credit ="" if image_credit == "Add Image Credit"
  end

  def handle_status_change
    if changed.map(&:to_sym).include?(:status)
      TileStatusChangeManager.new(self).process
    end
  end

  def requires_remote_media_url
    is_brand_new_tile? || setting_empty_image?
  end

  def setting_empty_image?
    self.persisted? && changed.include?("remote_media_url") && remote_media_url.blank?
  end

  def is_brand_new_tile?
    self.new_record? && !image.present?
  end

  def process_image
    ImageProcessJob.new(id, image_from_library).perform unless is_cloned?
  end

  def image_changed?
    changes.keys.include? "remote_media_url"
  end

  def set_image_processing
    self.thumbnail_processing = true
    self.image_processing =  true
  end
end
