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

  def self.unhidden
    where(hidden: false)
  end

  def self.same_demo(user)
    where(demo_id: user.demo_id)
  end

  def self.guest_user_acts
    where(user_type: GuestUser.to_s)
  end

  def self.user_acts
    where(user_type: User.to_s)
  end
end
