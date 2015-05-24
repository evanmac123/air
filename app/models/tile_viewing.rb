class TileViewing < ActiveRecord::Base
  belongs_to :tile
  counter_culture :tile, column_name: 'unique_viewings_count'
  counter_culture :tile, column_name: 'total_viewings_count', delta_column: 'views'
  belongs_to :user, polymorphic: true

  def increment
    update_attribute :views, (views + 1)
    self
  end

  scope :for_period, ->(b,e){where(:created_at => b..e)}


  def self.add tile, user
    viewing = where(tile: tile, user: user).first
    if viewing
      viewing.increment
    else
      create(tile: tile, user: user)
    end
  end

  def self.views tile, user
    viewing = where(tile: tile, user: user).first
    if viewing
      viewing.views
    else
      0
    end
  end

  def self.unique_views tile
    where(tile: tile).count
  end

  def self.total_views tile
    where(tile: tile).sum(:views)
  end

  def self.users_viewings tileid
    where(tile_id: tileid, user_type: 'User')
  end

  def self.guest_users_viewings tileid
    where(tile_id: tileid, user_type: 'GuestUser')
  end
end
