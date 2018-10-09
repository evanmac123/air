# frozen_string_literal: true

class TileViewing < ActiveRecord::Base
  belongs_to :tile
  belongs_to :user, polymorphic: true
  counter_culture :tile, column_name: "unique_viewings_count"
  counter_culture :tile, column_name: "total_viewings_count", delta_column: "views"

  def increment
    update_attribute :views, (views + 1)
    self
  end

  scope :for_period, ->(b, e) { where(created_at: b..e) }


  def self.add(tile, user)
    viewing = find_by(tile: tile, user: user)
    if viewing
      viewing.increment
    else
      create(tile: tile, user: user)
    end
  end

  def self.views(tile, user)
    find_by(tile: tile, user: user).try(:views) || 0
  end

  def self.unique_views(tile)
    where(tile: tile).count
  end

  def self.total_views(tile)
    where(tile: tile).sum(:views)
  end

  def self.users_viewings(tileid)
    where(tile_id: tileid, user_type: "User")
  end

  def self.guest_users_viewings(tileid)
    where(tile_id: tileid, user_type: "GuestUser")
  end
end
