class BoardMembership < ActiveRecord::Base
  #Fields on user model that facilitate backwards compatibility for for to bms:
  FIELDS_ON_A_BOARD_BY_BOARD_BASIS = %w(is_client_admin points tickets ticket_threshold_base location_id allowed_to_make_tile_suggestions)

  belongs_to :user
  belongs_to :demo, counter_cache: :users_count
  belongs_to :location

  as_enum :notification_pref, email: 0, text_message: 1, both: 2, unsubscribe: 3

	scope :admins, -> { where(:is_client_admin => true) }

  attr_accessor :role
  before_validation do
    if @role.present?
      self.is_client_admin = self.role == 'Administrator'
    end
    true
  end

  after_destroy do
    update_or_destroy_user
  end

  def role
    # FIXME: What is this? Are we using roles meaningfully? #REWRITE AUTH
    @role ||= begin
      if self.is_client_admin
        'Administrator'
      else
        'User'
      end
    end
  end

  def self.claimed
    where("joined_board_at IS NOT NULL")
  end

  def self.current
    where(is_current: true)
  end

  def self.uncurrent
    where(is_current: false)
  end

  def self.most_recently_posted_to
    includes(:demo).order("demos.tile_last_posted_at DESC")
  end

  #TODO figure a better way to handle this
  def update_or_destroy_user
    if user.board_memberships.empty?
      user.destroy
    elsif user.board_memberships.where(is_current: true).empty?
      user.board_memberships.first.update_attributes(is_current: true)
    end
  end

  def set_not_current
    set_current_board_dependent_attributes
    self.is_current = false
    self.save!
  end

  def set_as_current
    self.is_current = true
    set_joined_board_at
    self.save!

    load_updated_board_dependent_attributes
    user.reload
    self
  end

  private
    ####These are methods designed to faciliate backwards compatibility with moving to BMs.  They are lazy and should be removed:
    def set_current_board_dependent_attributes
      FIELDS_ON_A_BOARD_BY_BOARD_BASIS.each do |field|
        current_value = user.send(field)
        self.send("#{field}=", current_value)
      end
    end

    def load_updated_board_dependent_attributes
      FIELDS_ON_A_BOARD_BY_BOARD_BASIS.each do |field|
        current_value = self.send(field)
        user.send("#{field}=", current_value)
      end
      user.save!
    end
    ####

    def set_joined_board_at
      unless joined_board_at
        self.joined_board_at = Time.current
      end
    end
end
