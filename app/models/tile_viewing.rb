class TileViewing < ActiveRecord::Base
  belongs_to :tile
  belongs_to :user, polymorphic: true

  def self.add tile, user
    viewing = where(tile: tile, user: user).first
    if viewing
      viewing.increment
    else
      create(tile: tile, user: user)
    end
  end

  def self.unique_views tile
    where(tile: tile).count
  end

  def self.total_views tile
    where(tile: tile).sum(:views)
  end

  protected

  def increment
    update_attribute :views, (views + 1)
  end
end
