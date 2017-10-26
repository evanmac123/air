class Act < ActiveRecord::Base
  belongs_to :user, polymorphic: true
  belongs_to :referring_user, class_name: "User"
  belongs_to :demo

  before_save do
    self.hidden = self.text.blank?
    self.privacy_level = user.privacy_level
  end

  before_create do
    self.demo_id ||= user.demo.id
  end

  after_create do
    user.update_last_acted_at
    user.update_points(points) if points
  end

  scope :ordered, -> { order("created_at DESC") }

  def self.create_from_tile_completion(tile:, user:)
    Act.create(
      user: user,
      demo_id: user.demo_id,
      inherent_points: tile.points,
      text: "completed the tile: \"#{tile.headline}\""
    )
  end

  def points
    self.inherent_points || 0
  end

  def self.unhidden
    where(:hidden => false)
  end

  def self.same_demo(user)
    where(:demo_id => user.demo_id)
  end

  def self.guest_user_acts
    where(user_type: GuestUser.to_s)
  end

  def self.user_acts
    where(user_type: User.to_s)
  end

  def self.displayable_to_user(viewing_user:, page:, per_page:)
    board = viewing_user.demo
    if board.hide_social || viewing_user.is_a?(PotentialUser)
      return board.acts.ordered.where(user_id: viewing_user.id, user_type: User.to_s).page(page).per(per_page)
    end

    if viewing_user.is_client_admin || viewing_user.is_site_admin
      return board.acts.ordered.page(page).per(per_page)
    end

    if viewing_user.is_guest?
      return board.acts.guest_user_acts.where(user_id: viewing_user.id, user_type: GuestUser.to_s).ordered.page(page).per(per_page)
    end

    friends = viewing_user.displayable_accepted_friends
    viewable_user_ids = friends.pluck(:id) + [viewing_user.id]

    board.acts.user_acts.unhidden.where("(user_id in (?) or privacy_level='everybody')", viewable_user_ids).ordered.page(page).per(per_page)
  end

  def self.for_profile(viewing_user)
    displayable_to_user(viewing_user, viewing_user.demo, 1, 10)
  end
end
