class Tile < ActiveRecord::Base
  include Concerns::TileImageable

  ACTIVE  = 'active'.freeze
  ARCHIVE = 'archive'.freeze
  DRAFT   = 'draft'.freeze
  USER_DRAFT = 'user_draft'.freeze
  USER_SUBMITTED   = 'user_submitted'.freeze
  STATUS  = [ACTIVE, ARCHIVE, DRAFT, USER_DRAFT, USER_SUBMITTED].freeze
  #question types
  ACTION = 'Action'.freeze
  QUIZ   = 'Quiz'.freeze
  SURVEY = 'Survey'.freeze
  #question subtypes
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
  
  validates_presence_of :headline, :allow_blank => false, :message => "headline can't be blank"
  validates_presence_of :supporting_content, :allow_blank => false, :message => "supporting content can't be blank", :on => :client_admin
  validates_presence_of :question, :allow_blank => false, :message => "question can't be blank", :on => :client_admin

  validates_inclusion_of :status, in: STATUS

  validates_length_of :headline, maximum: 75, message: "headline is too long (maximum is 75 characters)"
  validates_with RawTextLengthInHTMLFieldValidator, field: :supporting_content, maximum: 450, message: "supporting content is too long (maximum is 450 characters)"

  before_save :ensure_protocol_on_link_address

  has_alphabetical_column :headline

  before_post_process :no_post_process_on_copy
  
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
    self.user_tile_copies_count
  end
  
  def like_count
    self.user_tile_likes_count
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

  def claimed_completion_percentage
    100.0 * tile_completions_count / demo.users.claimed.count
  end

  def is_placeholder?
    false
  end

  def copy_to_new_demo(new_demo, copying_user)
    CopyTile.new(new_demo, copying_user).copy_tile self
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

  def viewed_by user
    TileViewing.add(self, user) if user
  end

  def total_views
    total_viewings_count
  end

  def unique_views
    unique_viewings_count
  end

  def self.displayable_categorized_to_user(user, maximum_tiles)
    DisplayCategorizedTiles.new(user, maximum_tiles).displayable_categorized_tiles
  end

  def self.due_ids
    self.after_start_time_and_before_end_time.map(&:id)
  end


  def self.satisfiable_to_user(user)
    tiles_due_in_demo = after_start_time_and_before_end_time.where(demo_id: user.demo.id, status: ACTIVE)
    ids_completed = user.tile_completions.map(&:tile_id)
    satisfiable_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    satisfiable_tiles.sort_by(&:position).reverse
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

  def self.user_draft
    where("status = ?", USER_DRAFT).ordered_by_position
  end

  def self.user_submitted
    where(status: USER_SUBMITTED)
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
    needs_tiles = if status_name == ACTIVE || status_name == DRAFT
                    0
                  else 
                    ids.count >= 4 ? 0 : (4 - ids.count)
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

  def self.reorder_explore_page_tiles! tile_ids
    self.transaction do
      starting_priority = current_highest_explore_page_priority
      priority = starting_priority + 1

      tile_ids.reverse.each do |tile_id|
        self.find(tile_id).update_attribute(:explore_page_priority, priority)
        priority += 1
      end
    end
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

