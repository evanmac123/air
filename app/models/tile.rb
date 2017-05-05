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
  CHANGE_EMAIL         = "Change Email".parameterize("_").freeze
  MAX_HEADLINE_LEN = 75
  MAX_SUPPORTING_CONTENT_LEN = 700
  IMAGE_UPLOAD = "image-upload"
  IMAGE_SEARCH = "image-search"
  VIDEO_UPLOAD = "video-upload"

  acts_as_taggable_on :channels

  #enum column: creation_source_cd
  as_enum :creation_source, client_admin_created: 0, explore_created: 1, suggestion_box_created: 2

  belongs_to :demo
  belongs_to :creator, class_name: 'User'
  belongs_to :original_creator, class_name: 'User'

  has_one :organization, through: :demo

  has_many :tile_completions, :dependent => :nullify
  has_many :tile_viewings, dependent: :nullify
  has_many :tile_taggings, dependent: :nullify
  has_many :user_tile_likes, dependent: :nullify

  has_many :guest_user_viewers, through: :tile_viewings, source: :user, source_type: 'GuestUser'
  has_many :completed_tiles, source: :tile, through: :tile_completions
  has_many :user_viewers, through: :tile_viewings, source: :user, source_type: 'User'
  has_many :tile_tags, through: :tile_taggings
  has_alphabetical_column :headline

  before_validation :sanitize_supporting_content
  before_validation :sanitize_embed_video
  before_validation :remove_images, if: :image_set_to_blank

  before_create :set_on_first_position
  before_save :update_timestamps, if: :status_changed?
  before_save :ensure_protocol_on_link_address, :handle_suggested_tile_status_change
  before_save :set_image_credit_to_blank_if_default
  before_save :set_image_processing, if: :image_changed?
  after_save :process_image, if: :image_changed?

  validates_presence_of :headline, :allow_blank => false, :message => "headline can't be blank",  if: :state_is_anything_but_draft?
  validates_presence_of :supporting_content, :allow_blank => false, :message => "supporting content can't be blank", if: :state_is_anything_but_draft?
  validates_presence_of :question, :allow_blank => false, :message => "question can't be blank",  if: :state_is_anything_but_draft?
  validates_presence_of :remote_media_url, message: "image is missing" , if: :state_is_anything_but_draft?
  validate :multiple_choice_question, if: :state_is_anything_but_draft?
  validates_inclusion_of :status, in: STATUS

  validates_length_of :headline, maximum: MAX_HEADLINE_LEN, message: "headline is too long (maximum is #{MAX_HEADLINE_LEN} characters)"
  validates_with RawTextLengthInHTMLFieldValidator, field: :supporting_content, maximum: MAX_SUPPORTING_CONTENT_LEN, message: "supporting content is too long (maximum is #{MAX_SUPPORTING_CONTENT_LEN} characters)"

  def state_is_anything_but_draft?
     status != DRAFT
  end



  before_post_process :no_post_process_on_copy



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

  scope :explore, -> { explore_non_ordered.order("created_at DESC") }
  scope :explore_non_ordered, -> { where(is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE]) }

  scope :ordered_by_position, -> { order "position DESC" }

  alias_attribute :like_count, :user_tile_likes_count
  alias_attribute :total_views, :total_viewings_count
  alias_attribute :unique_views, :unique_viewings_count
  alias_attribute :interactions, :tile_completions_count

  after_save :reindex, if: :should_reindex?
  after_destroy :reindex

  searchkick word_start: [:channel_list, :headline], callbacks: false

  def search_data
    extra_data = {
      channel_list: channel_list,
      organization_name: organization.try(:name)
    }

    serializable_hash.merge(extra_data)
  end

  def should_reindex?
    self.changes.key?("headline") || self.changes.key?("supporting_content") || self.changes.key?("is_public")
  end

  def self.not_completed
    tiles = Tile.arel_table

    where(tiles[:id].not_in(completed.pluck(:id)))
  end

  def self.completed
    joins(:completed_tiles)
  end

  def airbo?
    organization.name == "Airbo"
  end


  # Dynamically define 'status?' instance methods  and scopes
  # TODO consider refactoring to remove metaprogramming here. prob not needed

  STATUS.each do |status_name|
    define_method(status_name + "?") do
      self.status == status_name
    end

    scope status_name.to_sym, -> { where(status: status_name).ordered_by_position }
  end

  # Custom Attribute Setter: ensure that setting/updating the 'status' updates the corresponding time-stamp
  def update_timestamps
    case status
    when ACTIVE  then
      if  never_activated || activated_at_reset_allowed?
        self.activated_at = Time.now
      end
    when ARCHIVE then
      self.archived_at  = Time.now
    end

  end

  def update_status params
    handle_unarchived(params["status"], params["redigest"])

    self.status = params["status"]
    self.position = find_new_first_position
    self.save
  end

  def organization_slug
    organization ? organization.slug : "airbo"
  end

  def organization_name
    organization ? organization.name : "airbo"
  end

  def archived?
    status == Tile::ARCHIVE
  end

  def handle_unarchived new_status, redigest
    if status == ARCHIVE && new_status == ACTIVE && redigest=="true"
      allow_activated_at_reset
    end
  end

  def is_fully_assembled?
    headline.present? && supporting_content.present? && question.present? && remote_media_url.present? && supporting_content_raw_text.length <= MAX_SUPPORTING_CONTENT_LEN && has_correct_answer_selected?
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

  def copy_inside_demo(new_demo, copying_user)
    TileCopier.new(new_demo, self, copying_user).copy_from_own_board
  end

  def copy_to_new_demo(new_demo, copying_user)
    TileCopier.new(new_demo, self, copying_user).copy_tile_from_explore
  end

  def find_new_first_position
    Tile.where(demo: self.demo, status: self.status).maximum(:position).to_i + 1
  end

  def viewed_by user
    TileViewing.add(self, user) if user
  end

  def self.featured_tile_ids(related_features)
    if related_features.present?
      tile_features = TileFeature.where(id: related_features.pluck(:id))
    else
      tile_features = TileFeature.scoped
    end

    tile_features.active.flat_map(&:tile_ids).compact
  end

  def self.explore_without_featured_tiles(related_features = nil)
    tiles_table = Arel::Table.new(:tiles)

    explore.where(tiles_table[:id].not_in(featured_tile_ids(related_features)))
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

  def self.next_manage_tile tile, offset, carousel = true
    tiles = where(status: tile.status, demo: tile.demo).ordered_by_position
    first_tile = carousel ? tiles.first : nil
    tiles[tiles.index(tile) + offset] || first_tile
  end


  def self.bulk_complete(demo_id, tile_id, emails)
    Delayed::Job.enqueue TileBulkCompletionJob.new(demo_id, tile_id, emails)
  end

  def self.find_additional_tiles_for_manage_section(status_name, presented_ids, tile_demo_id)
    FindAdditionalTilesForManageSection.new(status_name, presented_ids, tile_demo_id).find
  end

  def self.insert_tile_between left_tile_id, tile_id, right_tile_id, new_status = nil, redigest=false
    InsertTileBetweenTiles.new(left_tile_id, tile_id, right_tile_id, new_status, redigest).insert!
  end

  def self.reorder_explore_page_tiles! tile_ids
    ReorderExplorePageTiles.new(tile_ids).reorder
  end

  def self.displayable_tiles_select_clause
    [:id, :headline, :demo_id, :tile_completions_count, :thumbnail_file_name, :thumbnail_content_type, :thumbnail_file_size, :thumbnail_updated_at, :position]
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

  def prevent_activated_at_reset
    @activated_at_reset_allowed = false
  end

  def allow_activated_at_reset
   @activated_at_reset_allowed = true
  end

  def activated_at_reset_allowed?
    @activated_at_reset_allowed == true
  end

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

  def supporting_content_raw_text
    Nokogiri::HTML::Document.parse(supporting_content).text
  end

  private

  def multiple_choice_question
    unless( has_correct_answer_selected?)
      errors.add(:base, "Please select correct answer")
    end
  end

  def has_correct_answer_selected?
    if(question_type == QUIZ)
      correct_answer_index != -1
    else
      true
    end
  end


  def image_set_to_blank
    remote_media_url == ""
  end

  def remove_images
    write_attribute(:remote_media_url, nil)
    image.destroy

    # NOTE this destroy call is for consistency only. Paperclip is configured
    # with preserve_files: true for thumbnails so that thumbnails are never
    # deleted #see  TileImageable module for details
    thumbnail.destroy
  end

  #FIXME the code around handling update status has gotten quite ugly
  def already_activated
    (status == ACTIVE || status==ARCHIVE) && activated_at.present?
  end

  def never_activated
    !already_activated
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

  def handle_suggested_tile_status_change
    if changed.map(&:to_sym).include?(:status)
      TileStatusChangeManager.new(self).process
    end
  end

  def set_image_processing
    if remote_media_url.present?
      self.thumbnail_processing = true
      self.image_processing = true
    end
  end

  def process_image
    ImageProcessJob.new(id, image_from_library).perform unless is_cloned?
  end

  def image_changed?
    changes.keys.include? "remote_media_url"
  end
end
