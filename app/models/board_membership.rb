class BoardMembership < ActiveRecord::Base
  belongs_to :user
  belongs_to :demo
  belongs_to :location

	scope :admins, ->{where(:is_client_admin => true)}

  attr_accessor :role
  before_validation do
    if @role.present?
      self.is_client_admin = self.role == 'Administrator'
    end
    true
  end

  after_destroy do
    destroy_dependent_user
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

  def destroy_dependent_user
    _dependent_board_id = self.demo.dependent_board_id
    if _dependent_board_id
      _primary_user_id = self.user_id

      dependent_users = User.joins(:board_memberships).where do
        (primary_user_id == _primary_user_id) &
        (board_memberships.demo_id == _dependent_board_id)
      end

      dependent_users.each do |u|
        moved_to_other_board = RemoveUserFromBoard.new(u, _dependent_board_id).remove!
        u.destroy unless moved_to_other_board # last board
      end
    end
    true
  end
end
