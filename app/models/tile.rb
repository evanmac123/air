# frozen_string_literal: true

class Tile < ActiveRecord::Base
  include Tile::TileImageable
  include Tile::TileImageProcessing
  include Tile::TileQuestionTypes
  include Tile::TileAnswers
  include Tile::TileLinkTracking
  include Attachable

  ARCHIVE = "archive"
  ACTIVE  = "active"
  DRAFT   = "draft"
  PLAN    = "plan"
  USER_SUBMITTED = "user_submitted"
  IGNORED = "ignored"

  STATUS  = [ACTIVE, ARCHIVE, DRAFT, USER_SUBMITTED, IGNORED].freeze

  MAX_HEADLINE_LEN = 75
  MAX_SUPPORTING_CONTENT_LEN = 700
  IMAGE_UPLOAD = "image-upload"
  IMAGE_SEARCH = "image-search"
  VIDEO_UPLOAD = "video-upload"

  as_enum :creation_source, client_admin_created: 0, explore_created: 1, suggestion_box_created: 2

  belongs_to :demo
  belongs_to :creator, class_name: "User"
  belongs_to :original_creator, class_name: "User"

  has_one  :organization, through: :demo
  has_many :tile_completions, dependent: :nullify
  has_many :tile_viewings, dependent: :nullify
  has_many :tiles_digest_tiles, dependent: :destroy
  has_many :tiles_digests, through: :tiles_digest_tiles
  has_many :tile_user_notifications, dependent: :destroy
  has_many :campaign_tiles, dependent: :destroy
  has_many :campaigns, through: :campaign_tiles

  alias_attribute :total_views, :total_viewings_count
  alias_attribute :unique_views, :unique_viewings_count
  alias_attribute :interactions, :tile_completions_count

  before_validation :sanitize_supporting_content
  before_validation :sanitize_embed_video
  before_validation :remove_images, if: :image_set_to_blank

  before_create :set_on_first_position
  before_save :update_timestamps, if: :status_changed?
  before_save :set_image_credit_to_blank_if_default
  after_save :handle_suggested_tile_status_change

  validates_presence_of :headline, allow_blank: false, message: "headline can't be blank",  if: :state_is_anything_but_draft?
  validates_presence_of :supporting_content, allow_blank: false, message: "supporting content can't be blank", if: :state_is_anything_but_draft?
  validates_presence_of :question, allow_blank: false, message: "question can't be blank",  if: :state_is_anything_but_draft?
  validates_presence_of :remote_media_url, message: "image is missing", if: :state_is_anything_but_draft?
  validate :multiple_choice_question_answer_selected, if: :state_is_anything_but_draft?
  validates_inclusion_of :status, in: STATUS
  validates_length_of :headline, maximum: MAX_HEADLINE_LEN, message: "headline is too long (maximum is #{MAX_HEADLINE_LEN} characters)"
  validates_with RawTextLengthInHTMLFieldValidator, field: :supporting_content, maximum: MAX_SUPPORTING_CONTENT_LEN, message: "supporting content is too long (maximum is #{MAX_SUPPORTING_CONTENT_LEN} characters)"

  scope :suggested, -> do
    where(status: [USER_SUBMITTED, IGNORED]).order(status: :desc).ordered_by_position
  end

  scope :digest, ->(demo, cutoff_time) { cutoff_time.nil? ? active : active.where("activated_at > ?", cutoff_time) }

  scope :explore, -> { explore_non_ordered.order("tiles.created_at DESC") }
  scope :explore_not_in_campaign, -> { explore.joins("LEFT JOIN campaign_tiles ON campaign_tiles.tile_id = tiles.id").where(campaign_tiles: { id: nil }) }
  scope :explore_non_ordered, -> { where(is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE]) }

  scope :ordered_by_position, -> { order "position DESC" }

  after_save :reindex, if: :should_reindex?
  after_destroy :reindex

  searchkick word_start: [:headline], callbacks: false

  def self.default_search_fields
    ["headline^10", "supporting_content^8", :campaigns, :organization_name]
  end

  def search_data
    extra_data = {
      campaigns: campaigns.pluck(:name),
      organization_name: organization.try(:name)
    }

    serializable_hash.merge(extra_data)
  end

  def should_reindex?
    ["headline", "supporting_content", "is_public", "status"].any? { |key| self.changes.key?(key) }
  end

  def state_is_anything_but_draft?
    status != DRAFT
  end

  def remote_media_url
    if has_video?
      ActionController::Base.helpers.asset_path("video.png")
    else
      super
    end
  end

  def has_video?
    embed_video.present?
  end

  def airbo_created?
    organization.present? && organization.internal
  end

  def airbo_community_created?
    organization.present? && organization.internal.blank?
  end

  def tiles_digest
    tiles_digests.first
  end

  def sent_at
    tiles_digest.try(:sent_at)
  end

  STATUS.each do |status_name|
    define_method(status_name + "?") do
      self.status == status_name
    end

    scope status_name.to_sym, -> { where(status: status_name).ordered_by_position }
  end

  def update_timestamps
    case status
    when DRAFT
      self.activated_at = nil
    when ACTIVE
      if activated_at.nil?
        self.activated_at = Time.current
      end
    when ARCHIVE
      self.archived_at = Time.current
    end
  end

  def organization_name
    organization ? organization.name : "airbo"
  end

  def is_fully_assembled?
    headline.present? && supporting_content.present? && question.present? && remote_media_url.present? && supporting_content_raw_text.length <= MAX_SUPPORTING_CONTENT_LEN && has_correct_answer_selected? && has_unique_answers? && has_required_number_of_answers?
  end

  def points=(number)
    write_attribute(:points, number.to_i)
  end

  def image_credit=(text)
    write_attribute(:image_credit, text.try(:strip))
  end

  def suggested?
    ignored? || user_submitted?
  end

  def question_config
    if (question_type && question_subtype)
      {
        type: normalized_question_type,
        subtype: question_subtype,
        answers: multiple_choice_answers,
        question: question,
        index: correct_answer_index,
        allowFreeResponse: allow_free_response,
        signature: config_signature.downcase,
        isAnonymous: is_anonymous,
        points: points,
        tileId: id,
        isPublic: is_public,
        isSharable: is_sharable
      }
    else
      {}
    end
  end

  def config_signature
    add_config_options_to_base_signature([question_type, question_subtype]).join("_")
  end

  def is_survey?
    normalized_question_type == SURVEY.downcase || (question_type.nil? && correct_answer_index == -1)
  end

  def is_quiz?
    normalized_question_type == QUIZ.downcase || (question_type.nil? && correct_answer_index > 0)
  end

  def is_action?
    normalized_question_type == ACTION.downcase
  end

  def is_invite_spouse?
    question_subtype == INVITE_SPOUSE
  end

  def survey_chart
    SurveyChart.new(self).build
  end

  def is_placeholder?
    false
  end

  def find_new_first_position
    Tile.where(demo: self.demo, status: self.status).maximum(:position).to_i + 1
  end

  def viewed_by(user)
    TileViewing.add(self, user) if user
  end

  def self.displayable_categorized_to_user(user, maximum_tiles)
    DisplayCategorizedTiles.new(user, maximum_tiles).displayable_categorized_tiles
  end

  def prev_tile_in_board
    Tile::NeighborInBoardFinder.new(self).prev
  end

  def next_tile_in_board
    Tile::NeighborInBoardFinder.new(self).next
  end

  def set_on_first_position
    self.position = find_new_first_position
  end

  def supporting_content_raw_text
    Nokogiri::HTML::Document.parse(supporting_content).text
  end

  def has_attachments
    attachment_count > 0
  end

  def attachment_count
    @attaments ||= documents.count
  end

  private

    def add_config_options_to_base_signature(base)
      base.push "free_response" if allow_free_response
      base.push "is_anonymous" if  is_anonymous
      base
    end

    # TODO run migratio to downcase question type in DB remove this method
    def normalized_question_type
      question_type.try(:downcase)
    end

    def multiple_choice_question_answer_selected
      unless (has_correct_answer_selected?)
        errors.add(:base, "Please select correct answer")
      end
    end

    # TODO This method runs a check for something that should be impossible: !multiple_choice_answers.present?. I think this stems from poor coupling to test factories and is not actually necessary.
    def has_required_number_of_answers?
      if multiple_choice_answers.present?
        answers_count = multiple_choice_answers.length
        if min_one_answer_required
          answers_count > 0
        else
          answers_count > 1
        end
      else
        true
      end
    end

    def has_unique_answers?
      if multiple_choice_answers.present?
        multiple_choice_answers.length == multiple_choice_answers.uniq.length
      else
        true
      end
    end

    def has_correct_answer_selected?
      if (normalized_question_type == QUIZ.downcase)
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
      thumbnail.destroy
    end

    def sanitize_supporting_content
      self.supporting_content = Sanitize.fragment(
        strip_content,
        elements: [
          "ul", "ol", "li",
          "b", "strong", "i", "em", "u",
          "span", "div", "p",
          "br", "a"
        ],
        attributes: { "a" => ["href", "target"] }
      ).strip
    end

    def sanitize_embed_video
      self.embed_video = Sanitize.fragment(
        (self.embed_video.try(:strip) || ""),
        elements: ["iframe"],
        attributes: { "iframe" => ["src", "width", "height", "allowfullscreen", "webkitallowfullscreen", "mozAllowFullScreen", "frameborder", "allowtransparency", "frameborder", "scrolling", "class", "oallowfullscreen"] }
      ).strip
    end

    def strip_content
      supporting_content.try(:strip) || ""
    end

    def set_image_credit_to_blank_if_default
      self.image_credit = "" if image_credit == "Add Image Credit"
    end

    def handle_suggested_tile_status_change
      if suggestion_box_created? && changes.include?(:status)
        SuggestedTileStatusChangeManager.new(self).process
      end
    end

    def min_one_answer_required
      normalized_question_type == ACTION.downcase || ["free_response", "custom_form"].include?(question_subtype)
    end
end
