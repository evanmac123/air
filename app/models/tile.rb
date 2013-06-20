class Tile < ActiveRecord::Base
  ACTIVE  = 'active'.freeze
  ARCHIVE = 'archive'.freeze
  DRAFT   = 'draft'.freeze
  STATUS  = [ACTIVE, ARCHIVE, DRAFT].freeze

  belongs_to :demo

  has_many :prerequisites
  has_many :prerequisite_tiles, :class_name => "Tile", :through => :prerequisites
  has_many :rule_triggers, :class_name => "Trigger::RuleTrigger"
  has_one :survey_trigger, :class_name => "Trigger::SurveyTrigger"
  has_many :tile_completions, :dependent => :destroy
  has_many :triggering_rules, :class_name => "Rule", :through => :rule_triggers

  validates_uniqueness_of :position, :scope => :demo_id

  validates_presence_of :headline, :allow_blank => false, :message => "headline can't be blank"
  validates_presence_of :supporting_content, :allow_blank => false, :message => "supporting content can't be blank", :on => :client_admin
  validates_presence_of :question, :allow_blank => false, :message => "question can't be blank", :on => :client_admin

  validates_inclusion_of :status, in: STATUS

  validates_with AttachmentPresenceValidator, :attributes => [:image], :if => :require_images, :message => "image is missing"
  validates_with AttachmentPresenceValidator, :attributes => [:thumbnail], :if => :require_images

  attr_accessor :display_completion_on_this_request


  has_alphabetical_column :headline

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
    {:styles => {:carousel => ["238x238>", :png], :hover => ["258x258>", :png]},
    :default_style => :carousel,
    :default_url => "/assets/avatars/thumb/missing.png",
    :bucket => S3_TILE_THUMBNAIL_BUCKET}.merge(TILE_THUMBNAIL_OPTIONS)

  def name
    # this is only here so formtastic's input in app/views/admin/tiles/_form.haml
    # f.input :prerequisite_tiles, :collection => @existing_tiles 
    # still has a name attribute to reference
    headline
  end

  def satisfy_for_user!(user, channel=nil)
    completion = TileCompletion.create!(:tile_id => id, :user_id => user.id)
    #OutgoingMessage.send_side_message(user, completion.satisfaction_message, :channel => channel)
    Act.create!(:user_id =>user.id, :inherent_points => bonus_points, :text => "")
  end

  def due?
    now = Time.now
    return false if start_time && (start_time > now)
    return false if end_time && (end_time < now)
    true
  end

  def only_manually_triggerable?
    self.rule_triggers.empty? && self.survey_trigger.blank?
  end

  def all_rule_triggers_satisfied_to_user(user)
    return true unless self.poly
    required_rule_ids = rule_triggers.map(&:rule_id).to_set
    completed_rule_ids = Act.where(user_id: user.id).map(&:rule_id).to_set
    required_rule_ids.subset? completed_rule_ids
  end

  def has_rules_left_for_user(user)
    poly? && !all_rule_triggers_satisfied_to_user(user)
  end

  def first_rule
    first_trigger = rule_triggers.order("created_at ASC").first
    first_trigger && first_trigger.rule
  end

  def appears_client_created
    supporting_content.present? && question.present?
  end

  def archived?
    self.status == ARCHIVE
  end

  def self.due_ids
    self.after_start_time_and_before_end_time.map(&:id)
  end

  def self.displayable_to_user(user)
    satisfiable_tiles = satisfiable_to_user(user)
    recently_completed_ids = user.tile_completions.waiting_to_display_one_final_time.map(&:tile_id)
    recently_completed_tiles = Tile.where(id: recently_completed_ids)
    
    # Set the 'display_completion_on_this_request' flag if it was /just/ completed
    recently_completed_tiles = recently_completed_tiles.map do |tile|
      tile.display_completion_on_this_request = true
      tile
    end
    (satisfiable_tiles + recently_completed_tiles).sort_by(&:position)
  end

  def self.satisfiable_by_rule_to_user(rule_or_rule_id, user)
    satisfiable_by_rule(rule_or_rule_id).satisfiable_to_user(user)
  end

  def self.satisfiable_by_survey_to_user(survey_or_survey_id, user)
    satisfiable_by_survey(survey_or_survey_id).satisfiable_to_user(user)
  end

  def self.satisfiable_to_user(user)
    tiles_due_in_demo = after_start_time_and_before_end_time.where(demo_id: user.demo.id, status: ACTIVE)
    ids_completed = user.tile_completions.map(&:tile_id)
    satisfiable_tiles = tiles_due_in_demo.reject {|t| ids_completed.include? t.id}
    # Reject the ones whose prereqs have not been met
    satisfiable_tiles.reject! do |t|
      hide = false
      t.prerequisites.each do |p|
        unless ids_completed.include? p.prerequisite_tile_id
          hide = true
        end
      end
      hide
    end
    satisfiable_tiles.sort_by(&:position)
  end

  def self.satisfiable_to_user_with_sample(user)
    satisfiable_tiles = satisfiable_to_user(user)
    if user.tutorial_active?
      satisfiable_tiles.prepend(SampleTile.new)
    else
      satisfiable_tiles
    end
  end

  def self.displayable_to_user_with_sample(user)
    displayable_tiles = displayable_to_user(user)
    if user.tutorial_active?
      displayable_tiles.prepend(SampleTile.new)
    else
      displayable_tiles
    end
  end

  def self.active
    where("status = ?", ACTIVE)
  end

  def self.archive
    where("status = ?", ARCHIVE)
  end

  def self.draft
    where("status = ?", DRAFT)
  end

  def self.digest(demo)
    active.where("created_at > ?", demo.tile_digest_email_sent_at)
  end

  def self.archive_if_expired
    expired.each { |tile| tile.update_attributes status: ARCHIVE }
  end

  def self.expired
    active.where("end_time IS NOT NULL AND end_time < ?", Time.now)
  end

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

  def self.satisfiable_by_rule(rule_or_rule_id)
    satisfiable_by_object(rule_or_rule_id, Rule, "trigger_rule_triggers", "rule_id")
  end

  def self.satisfiable_by_survey(survey_or_survey_id)
    satisfiable_by_object(survey_or_survey_id, Survey, "trigger_survey_triggers", "survey_id")
  end

  def self.next_position(demo)
    if table_exists?
      where(demo_id: demo.id).maximum(:position).to_i + 1
    else
      1
    end
  end

  def self.set_position_within_demo(demo, id_order)
    count = 1 # Using 1-based counting since the admins see this number
    id_order.each do |tile_id|
      where(id: tile_id).each do |tile|
        tile.update_column(:position, count)
      end
      count += 1
    end
  end

  protected

  def self.satisfiable_by_trigger_table(trigger_table_name)
    joins("INNER JOIN #{trigger_table_name} ON #{trigger_table_name}.tile_id = tiles.id")
  end

  def self.satisfiable_by_object(satisfying_object_or_id, satisfying_object_class, trigger_table_name, satisfying_object_column)
    satisfying_object_id = triggering_object_id(satisfying_object_or_id, satisfying_object_class)
    satisfiable_by_trigger_table(trigger_table_name).where("#{trigger_table_name}.#{satisfying_object_column} = ?", satisfying_object_id)
  end

  def self.triggering_object_id(object_or_object_id, expected_class)
    object_or_object_id.kind_of?(expected_class) ? object_or_object_id.id : object_or_object_id
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

        unless user.demo_id == @demo_id.to_i
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

