class AirboSearch
  ADMIN_PER_PAGE = 20
  USER_PER_PAGE = 20
  OVERVIEW_LIMIT = 3 #index value

  attr_accessor :query, :user, :demo, :options

  def initialize(query, user, options = {})
    @query = query
    @user = user
    @demo = get_demo
    @options = options
  end

  def user_tiles(page = 1)
    if user_search
      @user_tiles ||= demo.tiles.search(formatted_query, user_tiles_options([Tile::ACTIVE], page))
    end
  end

  def client_admin_tiles(page = 1)
    if admin_search
      @client_admin_tiles ||= Tile.search(formatted_query, user_tiles_options([Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE], page))
    end
  end

  def explore_tiles(page = 1)
    if explore_search
      @explore_tiles ||= Tile.search(formatted_query, explore_tiles_options(page))
    end
  end

  def campaigns
    if explore_search
      @campaigns ||= Campaign.search(query, { order: [_score: :desc, created_at: :desc] })
    end
  end

  def total_result_count
    [user_tiles, client_admin_tiles, explore_tiles, campaigns].map { |results| get_count(results) }.sum
  end

  def overview_limit
    OVERVIEW_LIMIT
  end

  def tiles_present?
    user_tiles.present? || explore_tiles.present? || campaigns.present?
  end

  def track_initial_search
    tracking = Searchjoy::Search.create(
      search_type: search_type_tracking,
      query: query,
      results_count: total_result_count,
    )

    #Quick fix to SearchJoy incompatibility with Rails 3.2 mass asignment.  Explore alternate options.
    tracking.user_id = user_id_tracking,
    tracking.demo_id = demo_id_tracking,
    tracking.user_email = user_email_tracking

    tracking.save
  end

  private

    def get_count(results)
      results ? results.total_count : 0
    end

    def formatted_query
      return '*' if query.blank?
      query
    end

    def default_fields
      ["headline^10", "supporting_content^8", :channel_list, :organization_name]
    end

    def demo_id
      demo.id
    end

    def user_tiles_options(tile_status, page)
      {
        where: {
          demo_id: demo_id,
          status:  tile_status
        }
      }.merge(default_tile_options(page))
    end

    def client_admin_tiles_options(tile_status, page)
      {
        where: {
          demo_id: demo_id,
          status:  tile_status
        }
      }.merge(default_tile_options(page))
    end

    def explore_tiles_options(page)
      {
        where: {
          is_public: true,
          status: [Tile::ACTIVE, Tile::ARCHIVE]
        }
      }.merge(default_tile_options(page))
    end

    def default_tile_options(page)
      {
        fields: default_fields,
        order: [_score: :desc, created_at: :desc],
        page: page,
        per_page: per_page
      }
    end

    def per_page
      options[:per_page] || per_page_by_user
    end

    def per_page_by_user
      if admin_search
        ADMIN_PER_PAGE
      else
        USER_PER_PAGE
      end
    end

    def admin_search
      user.is_a?(User) && (user.is_client_admin || user.is_site_admin)
    end

    def user_search
      user.is_a?(User) && user.end_user?
    end

    def explore_search
      user.is_a?(GuestUser) || admin_search
    end

    def get_demo
      if user.is_a?(User)
        user.demo
      end
    end

    def search_type_tracking
      if user.is_a?(User)
        if user.end_user?
          "User Search"
        elsif user.is_site_admin
          "SA Search"
        else
          "CA Search"
        end
      else
        "Guest Search"
      end
    end

    def user_id_tracking
      if user.is_a?(User)
        user.id
      end
    end

    def demo_id_tracking
      if user.is_a?(User)
        user.demo_id
      end
    end

    def  user_email_tracking
      if user.is_a?(User)
        user.email
      end
    end
end
