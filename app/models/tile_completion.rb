class TileCompletion < ActiveRecord::Base
  ORDER_BY_USER_NAME    = 'users.name'.freeze
  ORDER_BY_USER_EMAIL   = 'users.email'.freeze
  ORDER_BY_USER_JOINED  = 'users.accepted_invitation_at'.freeze
  ORDER_BY_TILE_VIEWS   = 'tile_viewings.views'.freeze

  belongs_to :user, polymorphic: true
  belongs_to :tile, counter_cache: true

  validates_uniqueness_of :tile_id, :scope => [:user_id, :user_type]

  after_create :creator_has_tile_completed

  def creator_has_tile_completed
    # OPTZ: this can run asynchronously
    
    creator = self.tile.creator
    if creator.nil? == false && 
       creator.has_own_tile_completed == false && 
       creator != self.user &&
       creator.creator_tile_completions.limit(2).length == 1 
       # is the TileCompletion we just created the only one?
       # The "limit 2" there is a DB optimization: we were getting long-running
       # queries due to counting up ALL tile completions for this creator when 
       # all we really want to know is, is there more than one. Throwing in the
       # limit turned a typical query from 500 ms to 0.1 ms, or a 5000X 
       # speedup. Not bad for less than ten extra characters.
      
      creator.mark_own_tile_completed(self.tile)
    end
  end

  def self.for_tile(tile)
    where(:tile_id => tile.id)
  end

  def self.user_completed_any_tiles?(user_id, tile_ids)
    where(user_id: user_id, tile_id: tile_ids).count > 0
  end
  
  def has_user_joined?
    user.claimed?
  end

  def views
    TileViewing.views(tile, user)
  end

  def answer
    tile.multiple_choice_answers[answer_index]
  end
  #
  # => Methods For Wice Grid
  #
  def self.tile_completions_with_users tileid
    users_viewings_subquery = TileViewing.users_viewings(tileid)
    guest_users_viewings_subquery = TileViewing.guest_users_viewings(tileid)

    TileCompletion
      .includes{tile}
      .joins{user(User).outer}
      .joins{user(GuestUser).outer}
      .joins do
        "LEFT JOIN (" +
         users_viewings_subquery.to_sql +
        ") AS users_viewings " + 
        "ON users_viewings.user_id = users.id"
      end
      .joins do
        "LEFT JOIN (" +
         guest_users_viewings_subquery.to_sql +
        ") AS guest_users_viewings " + 
        "ON guest_users_viewings.user_id = guest_users.id"
      end
      .where{tile_id == tileid}
  end

  def self.tile_completion_grid_params
    {
      name: 'tc_grid', order: 'created_at', order_direction: 'desc',
      custom_order: {

        ORDER_BY_USER_NAME   => "CASE WHEN #{User.table_name}.id IS NULL 
                                 THEN 'Guest User[' || #{GuestUser.table_name}.id ||']' 
                                 ELSE #{User.table_name}.name END",

        ORDER_BY_USER_EMAIL  => "CASE WHEN #{User.table_name}.id IS NULL 
                                 THEN 'guest_user' || #{GuestUser.table_name}.id ||'@example.com' 
                                 ELSE #{User.table_name}.email END",

        ORDER_BY_USER_JOINED => "CASE WHEN #{User.table_name}.id IS NULL 
                                 THEN NULL 
                                 ELSE #{User.table_name}.accepted_invitation_at END",

        ORDER_BY_TILE_VIEWS  => "CASE WHEN #{User.table_name}.id IS NULL 
                                 THEN guest_users_viewings.views 
                                 ELSE users_viewings.views END"
      
      },
      enable_export_to_csv: true,
      csv_file_name: "tile_completions_report_#{DateTime.now.strftime("%d_%m_%y")}"
    }
  end

  def self.non_completions_with_users tile
    demoid = tile.demo.id
    tileid = tile.id
    users_viewings_subquery = TileViewing.users_viewings(tileid)

    User.joins{tile_completions.outer}
        .joins do 
          "LEFT JOIN (" +
           users_viewings_subquery.to_sql +
          ") AS tile_viewings " + 
          "ON tile_viewings.user_id = users.id"
        end
        .where do
          (demo_id == demoid) &&
          (tile_completions.tile_id == tileid) &&
          (tile_completions.id == nil)
        end
  end

  def self.non_completion_grid_params
    {
      name: 'nc_grid', 
      order: 'name', 
      order_direction: 'asc',
      enable_export_to_csv: true,
      csv_file_name: "non_completions_report_#{DateTime.now.strftime("%d_%m_%y")}"
    }
  end
end
