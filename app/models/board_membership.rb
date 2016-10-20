class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo
  belongs_to :location

	scope :admins, ->{ where(:is_client_admin => true) }

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
    @role ||= begin
      if self.is_client_admin
        'Administrator'
      else
        'User'
      end
    end
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

  def update_or_destroy_user
    if user.board_memberships.empty?
      user.destroy
    elsif user.board_memberships.where(is_current: true).empty?
      user.board_memberships.first.update_attributes(is_current: true)
    end
  end
end
