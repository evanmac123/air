class Tile < ActiveRecord::Base
  include Assets::Normalizer # normalize filename of paperclip attachment
  extend ValidImageMimeTypes

  ACTIVE  = 'active'.freeze
  ARCHIVE = 'archive'.freeze
  DRAFT   = 'draft'.freeze
  STATUS  = [ACTIVE, ARCHIVE, DRAFT].freeze
  #question types
  ACTION = 'Action'.freeze
  QUIZ   = 'Quiz'.freeze
  SURVEY = 'Survey'.freeze
  #question subtypes
  DO_SOMETHING          = "Do something".parameterize("_").freeze
  READ_TILE             = "Read Tile".parameterize("_").freeze
  READ_ARTICLE          = "Read Article".parameterize("_").freeze
  SHARE_ON_SOCIAL_MEDIA = "Share On Social Media".parameterize("_").freeze
  VISIT_WEB_SITE        = "Visit Web Site".parameterize("_").freeze
  WATCH_VIDEO           = "Watch Video".parameterize("_").freeze
  CUSTOM                = "Custom...".parameterize("_").freeze
  TRUE_FALSE            = "True / False".parameterize("_").freeze
  MULTIPLE_CHOICE       = "Multiple Choice".parameterize("_").freeze
  RSVP_TO_EVENT         = "RSVP to event".parameterize("_").freeze


  IMAGE_PROCESSING_IMAGE_URL = ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  THUMBNAIL_PROCESSING_IMAGE_URL = ActionController::Base.helpers.asset_path('resizing_gears_fullsize.gif')
  TILE_IMAGE_PROCESSING_PRIORITY = -10

  belongs_to :demo
  belongs_to :creator, class_name: 'User'
  belongs_to :original_creator, class_name: 'User'

  has_many :tile_completions, :dependent => :destroy
  has_many :completed_tiles, source: :tile, through: :tile_completions
  has_many :tile_taggings, dependent: :destroy
  has_many :tile_tags, through: :tile_taggings
  has_many :user_tile_copies, dependent: :destroy
  has_many :user_tile_likes, dependent: :destroy
  
  validates_presence_of :headline, :allow_blank => false, :message => "headline can't be blank"
  validates_presence_of :supporting_content, :allow_blank => false, :message => "supporting content can't be blank", :on => :client_admin
  validates_presence_of :question, :allow_blank => false, :message => "question can't be blank", :on => :client_admin

  validates_inclusion_of :status, in: STATUS

  validates_length_of :supporting_content, maximum: 300, message: "supporting content is too long (maximum is 300 characters)"
  validates_length_of :headline, maximum: 75, message: "headline is too long (maximum is 75 characters)"

  validates_with AttachmentPresenceValidator, :attributes => [:image], :if => :require_images, :message => "image is missing"
  validates_with AttachmentPresenceValidator, :attributes => [:thumbnail], :if => :require_images

  validates_with AttachmentSizeValidator, :less_than => (2.5).megabytes, :message => " the image is too large, please use a smaller file", :attributes => [:image], :if => :require_images

  validates_attachment_content_type :image, content_type: valid_image_mime_types, message: invalid_mime_type_error

  before_save :ensure_protocol_on_link_address

  has_alphabetical_column :headline

  validate do
    errors.add(:tile_tags, 'must exist for public tile') if is_public? && (tile_taggings.size < 1 && tile_tags.size < 1)
  end
  # The ":default_url => ~~~" option was not needed for Capy 1.x, but then Capy2 came along and started skipping
  # cucumber features without giving a reason. Specifically, one scenario in a feature file would pass, but
  # all subsequent ones would just be skipped. No reason was given - just a "Skipped step" output for each step.
  #
  # The frustrating part was the all of the failing tests would pass if run individually.
  #
  # Turns out that Tiles always (well, almost always - see the next paragraph) require a corresponding thumbnail,
  # as witnessed by the "validates_with AttachmentPresenceValidator" above and the default for ':require_images'
  # being set to 'true' in the migration.
  #
  # However, the Factory for a Tile sets 'require_images' to 'false' => '/thumbnails/carousel/missing.png' and
  # '/thumbnails/hover/missing.png' were being generated (by Paperclip) for the default tile image path when one
  # wasn't provided in Test mode, which happened a lot because we normally don't care about the specific image.
  #
  # The fact that these 2 files do not exist never caused a problem in pre-Capy2 days, but with Capy2 they led to the
  # behavior described above, i.e. the first cuke scenario generated an "HTML 500 response code - Internal Server Error"
  # which had no effect on the test that spawned the error, but which would cause all subsequent steps to be skipped!
  #
  # BTW, none of this info appeared in the 'test.log' file; you have to set "Capybara.javascript_driver = :webkit_debug"
  # in 'support/env.rb' in order to see it.
  #
  # Can you say: WTF!!!!! (I sure can!)

  has_attached_file :image,
    {
    # For those of you who don't read ImageMagick geometry arguments like a
    # native, "666>" means "Leave images under 666 pixels wide alone. Scale
    # down images over 666 pixels wide to 666 wide, maintaining the original
    # aspect ratio."
    :styles => {:viewer => ["666>", :png]},
    :default_style => :viewer,
    :default_url => "/assets/avatars/thumb/missing.png",
    :bucket => S3_TILE_BUCKET}.merge(TILE_IMAGE_OPTIONS)

  has_attached_file :thumbnail,
    {
    :styles =>
      { :carousel     => ["238x238#", :png],
      :email_digest => ["190x160#", :png]
    },
    :default_style   => :carousel,
    :default_url     => "/assets/avatars/thumb/missing.png",
    :bucket          => S3_TILE_THUMBNAIL_BUCKET}.merge(TILE_THUMBNAIL_OPTIONS)

  before_post_process :no_post_process_on_copy
  process_in_background :image, :processing_image_url => IMAGE_PROCESSING_IMAGE_URL, :priority => TILE_IMAGE_PROCESSING_PRIORITY
  process_in_background :thumbnail, :processing_image_url => THUMBNAIL_PROCESSING_IMAGE_URL, :priority => TILE_IMAGE_PROCESSING_PRIORITY

  # This is a hack to make processing graphic tests work right. Usually
  # enqueue_delayed_processing would run in an after_commit hook, but our
  # tests all run within one transaction, and trying to fuck with
  # use_transactional_fixtures and DatabaseCleaner to get JUST THESE tests
  # to run outside of a transaction made me wanna throw my computer out of
  # the window. So fuck that. Fuck fuck fuck.

  if Rails.env.test?
    after_save do
      unless $TESTING_COPYING
        enqueue_delayed_processing
      end
    end
  end

  scope :activated, -> {where(status: ACTIVE)}
  scope :archived, -> {where(status: ARCHIVE)}
  # Custom Attribute Setter: ensure that setting/updating the 'status' updates the corresponding time-stamp
  def status=(status)
    case status
    when ACTIVE  then self.activated_at = Time.now
    when ARCHIVE then self.archived_at  = Time.now
    end
    write_attribute(:status, status)
  end

  def name
    # this is only here so formtastic's input in app/views/admin/tiles/_form.haml
    # f.input :prerequisite_tiles, :collection => @existing_tiles
    # still has a name attribute to reference
    headline
  end

  def satisfy_for_user!(user)
    completion = TileCompletion.create!(:tile_id => id, :user => user)
    Act.create!(:user => user, :inherent_points => bonus_points, :text => "")
  end

  def due?
    now = Time.now
    return false if start_time && (start_time > now)
    return false if end_time && (end_time < now)
    true
  end
  
  def copy_count
    self.user_tile_copies.count
  end
  
  def like_count
    self.user_tile_likes.count
  end
  
  def appears_client_created
    supporting_content.present? && question.present?
  end

  def active?
    self.status == ACTIVE
  end

  def archived?
    self.status == ARCHIVE
  end

  def draft?
    self.status == DRAFT
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

  # XTR this into a value object
  def survey_chart
    chart = []
    count = TileCompletion.where(tile_id: self).count
    self.multiple_choice_answers.each_with_index do |answer, i|
      chart[i] = {}
      chart[i]["answer"] = answer 
      chart[i]["number"] = TileCompletion.where(tile_id: self, answer_index: i).count
      chart[i]["percent"] = if count > 0
        (chart[i]["number"].to_f * 100 / count).round(2).to_s + "%"
      else
        "0%"
      end
    end
    chart
  end

  def text_of_completion_act
    "completed the tile: \"#{headline}\""
  end

  def to_form_builder
    TileBuilderForm.new(demo, tile: self)
  end

  def image_really_still_processing
    image_url = image.url
    image_processing || image_url.nil? || image_url == Tile::IMAGE_PROCESSING_IMAGE_URL
  end

  def thumbnail_really_still_processing
    thumbnail_url = thumbnail.url
    thumbnail_processing || thumbnail_url.nil? || thumbnail_url == Tile::THUMBNAIL_PROCESSING_IMAGE_URL
  end

  def claimed_completion_percentage
    100.0 * tile_completions_count / demo.users.claimed.count
  end

  def is_placeholder?
    false
  end

  # XTR this into a service
  def copy_to_new_demo(new_demo, copying_user)
    @making_copy = true # prevents processing that we don't need
    copy = Tile.new
    %w(correct_answer_index headline link_address multiple_choice_answers points question supporting_content type image_meta thumbnail_meta image thumbnail).each do |field_to_copy|
      copy.send("#{field_to_copy}=", self.send(field_to_copy))
    end

    copy.status = Tile::DRAFT
    copy.original_creator = self.creator || self.original_creator
    copy.original_created_at = self.created_at || self.original_created_at
    copy.demo = new_demo
    copy.creator = copying_user
    copy.position = copy.find_new_first_position
    
    #mark as copied by user
    self.user_tile_copies.build(user_id: copying_user.id)
    self.save!
    copy.save!    
    copy
  end

  def human_original_creator_identification
    return "" unless original_creator.present?
    "#{original_creator.name}, #{original_creator.demo.name}"
  end

  def human_original_creation_date
    return "" unless original_created_at.present?
    original_created_at.strftime("%B %-e, %Y")
  end

  def first_tag
    self.tile_tags.first
  end

  def update_status status
    self.status = status
    self.position = find_new_first_position
    self.save
  end

  def find_new_first_position
    Tile.where(demo: self.demo, status: self.status).maximum(:position).to_i + 1
  end

  def left_tile
    self_demo = self.demo
    self_status = self.status
    self_position = self.position
    Tile.where{ 
      (demo == self_demo) & 
      (status == self_status) &
      (position > self_position)
    }.order("position ASC").first
  end

  def right_tile
    self_demo = self.demo
    self_status = self.status
    self_position = self.position
    Tile.where{ 
      (demo == self_demo) & 
      (status == self_status) &
      (position < self_position)
    }.ordered_by_position.first
  end

  # need this function to set height of image place in ie8 while image is loading
  def full_size_image_height
    if image.to_s.include? "/assets/avatars/thumb/missing.png"
      return nil
    elsif image.to_s.include? "/assets/resizing_gears_fullsize.gif"
      height = 484
      width = 666
    else
      height = image.height
      width = image.width
    end
    full_width = 600.0 # px for full size tile
    ( height * full_width / width ).to_i
  end

  def self.due_ids
    self.after_start_time_and_before_end_time.map(&:id)
  end

  def self.displayable_categorized_to_user(user, maximum_tiles)
    result = satisfiable_categorized_to_user(user) 

    if maximum_tiles
      #default for maximum tiles variant. if wrong will be changed
      result[:all_tiles_displayed] = false  

      length_not_completed = result[:not_completed_tiles].length
      length_completed = result[:completed_tiles].length
      if length_not_completed > maximum_tiles
        result[:not_completed_tiles] = result[:not_completed_tiles][0, maximum_tiles]
        result[:completed_tiles] = nil
      elsif (length_not_completed + length_completed) > maximum_tiles
        result[:completed_tiles] = result[:completed_tiles][0, maximum_tiles - length_not_completed]        
      else
        result[:all_tiles_displayed] = true      
      end
      result
    end

    result
  end

  def self.satisfiable_to_user(user)
    tiles_due_in_demo = after_start_time_and_before_end_time.where(demo_id: user.demo.id, status: ACTIVE)
    ids_completed = user.tile_completions.map(&:tile_id)
    satisfiable_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    satisfiable_tiles.sort_by(&:position).reverse
  end

  def self.satisfiable_categorized_to_user(user)
    tiles_due_in_demo = after_start_time_and_before_end_time.where(demo_id: user.demo.id, status: ACTIVE)
    completed_tiles = user.tile_completions.order("#{TileCompletion.table_name}.id desc").includes(:tile).where("#{Tile.table_name}.demo_id" => user.demo_id).map(&:tile)
    ids_completed = completed_tiles.map(&:id)
    not_completed_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    
    {completed_tiles: completed_tiles, not_completed_tiles: not_completed_tiles.sort_by(&:position).reverse}
  end
  
  def self.active
    where("status = ?", ACTIVE).ordered_by_position
  end

  def self.archive
    where("status = ?", ARCHIVE).ordered_by_position
  end

  def self.draft
    where("status = ?", DRAFT).ordered_by_position
  end

  def self.digest(demo, cutoff_time)
    cutoff_time.nil? ? active : active.where("activated_at > ?", cutoff_time)
  end

  def self.viewable_in_public
    where(is_sharable: true, is_public: true, status: [Tile::ACTIVE, Tile::ARCHIVE])
  end

  def self.copyable
    viewable_in_public.where(is_copyable: true)
  end

  def self.tagged_with(tag_id)
    unless tag_id.present?
      where("true")
    else
      tagged_tile_ids = TileTagging.where(tile_tag_id: tag_id).pluck(:tile_id)
      where(id: tagged_tile_ids)
    end
  end

  def self.ordered_for_explore
    order("explore_page_priority DESC NULLS LAST").order("created_at DESC")
  end

  def self.current_highest_explore_page_priority
    real_priority = select("MAX(explore_page_priority) AS explore_page_priority").first.explore_page_priority 
    real_priority || -1
  end

  def self.ordered_by_position
    order "position DESC"
  end

  def self.next_public_tile tile_id, offset, tag_id
    tiles = Tile.viewable_in_public.ordered_for_explore.tagged_with(tag_id)
    tile = Tile.viewable_in_public.where(id: tile_id).first
    next_tile = tiles[tiles.index(tile) + offset] || tiles.first # if index out of length
    next_tile || tile # i.e. we have only one tile so next tile is nil
  end

  def self.next_manage_tile tile, offset
    tiles = where(status: tile.status, demo: tile.demo).ordered_by_position
    tiles[tiles.index(tile) + offset] || tiles.first
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

  def self.after_start_time_and_before_end_time
    after_start_time.before_end_time
  end

  def self.after_start_time
    where("start_time < ? OR start_time IS NULL", Time.now)
  end

  def self.before_end_time
    where("end_time > ? OR end_time IS NULL", Time.now)
  end

  def self.bulk_complete(demo_id, tile_id, emails)
    Delayed::Job.enqueue TileBulkCompletionJob.new(demo_id, tile_id, emails)
  end

  def self.find_additional_tiles_for_manage_section(status_name, presented_ids, tile_demo_id)
    ids = presented_ids || []
    needs_tiles = if status_name == ACTIVE
                    0
                  else 
                    ids.count >= 8 ? 0 : (8 - ids.count)
                  end
    return [] if needs_tiles == 0

    Tile.where{ 
      (demo_id == tile_demo_id) & 
      (status == status_name) & 
      (id.not_in ids) 
    }.ordered_by_position.first(needs_tiles)
  end

  def self.insert_tile_between left_tile_id, tile_id, right_tile_id, new_status = nil
    InsertTileBetweenTiles.new(left_tile_id, tile_id, right_tile_id, new_status).insert!
  end

  protected

  def ensure_protocol_on_link_address
    return unless link_address_changed?
    return if link_address =~ %r{^(http://|https://)}i
    return if link_address.blank?

    self[:link_address] = "http://#{link_address}"
  end

  def no_post_process_on_copy
    !(@making_copy)
  end

  class TileBulkCompletionJob
    def initialize(demo_id, tile_id, emails)
      @demo_id = demo_id
      @tile_id = tile_id
      @emails = emails
    end

    def perform
      completion_states = {}
      %w(completed unknown already_completed in_different_game).each {|bucket| completion_states[bucket.to_sym] = []}

      tile = Tile.find(@tile_id)

      @emails.each do |email|
        user = User.find_by_either_email(email)

        unless user
          completion_states[:unknown] << email
          next
        end

        unless user.demo_ids.include? @demo_id.to_i
          completion_states[:in_different_game] << email
          next
        end

        if Tile.satisfiable_to_user(user).include? tile
          tile.satisfy_for_user!(user)
          completion_states[:completed] << email
        else
          completion_states[:already_completed] << email
        end

      end

      BulkCompleteMailer.delay_mail(:report, completion_states)
    end
  end
end

