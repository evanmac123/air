class AirboSearch
  ADMIN_PER_PAGE = 20
  USER_PER_PAGE = 12
  OVERVIEW_LIMIT = 3 #index value

  attr_accessor :query, :user, :demo, :options

  def initialize(query, user, options = {})
    @query = query
    @user = user
    @demo = get_demo
    @options = options
  end

  def user_tiles(page = 1)
    if admin_search
      @user_tiles ||= Tile.search(formatted_query, user_tiles_options([Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE], page))
    elsif user_search
      @user_tiles ||= Tile.search(formatted_query, user_tiles_options([Tile::ACTIVE, Tile::ARCHIVE], page))
    end
  end

  def explore_tiles(page = 1)
    if explore_search
      @explore_tiles ||= Tile.search(formatted_query, explore_tiles_options(page))
    end
  end

  def campaigns
    if admin_search
      @campaigns ||= Campaign.search(query, { order: [_score: :desc, created_at: :desc] })
    end
  end

  def total_result_count
    user_tiles.total_count + explore_tiles.total_count + campaigns.total_count
  end

  private

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
        },
        track: search_tracking_data,
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
      user_search && (user.is_client_admin || user.is_site_admin)
    end

    def user_search
      user.is_a?(User)
    end

    def explore_search
      user.is_a?(GuestUser) || admin_search
    end

    def get_demo
      if user_search
        user.demo
      end
    end

    def search_tracking_data
      if user.is_a?(User)
        { user_id: user.id, user_email: user.email }
      elsif user.is_a?(GuestUser)
        {}
      end
    end
end
