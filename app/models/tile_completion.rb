# frozen_string_literal: true

require "ostruct"
class TileCompletion < ActiveRecord::Base
  serialize :custom_form, Hash
  belongs_to :user, polymorphic: true
  belongs_to :tile, counter_cache: true

  scope :for_period, ->(b, e) { where(created_at: b..e) }

  validates_uniqueness_of :tile_id, scope: [:user_id, :user_type]

  after_create :update_user_points
  after_create :create_act

  def custom_data
    @custom_form = OpenStruct.new(custom_form)
  end

  def update_user_points
    user.update_points(tile.points)
  end

  def create_act
    unless tile.is_anonymous?
      ActFromTileCreatorJob.perform_later(tile: tile, user: user)
    end
  end
end
