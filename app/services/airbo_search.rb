class AirboSearch
  ADMIN_PER_PAGE = 20
  USER_PER_PAGE = 12

  attr_accessor :query, :user, :demo, :options

  def initialize(query, user, options = {})
    @query = query
    @user = user
    @demo = get_demo
    @options = options
  end

  def user_tiles(page = 1)
    unpaginated_user_tiles.records.page(page).per(per_page)
  end

  def explore_tiles(page = 1)
    if explore_search
      unpaginated_explore_tiles.records.page(page).per(per_page)
    end
  end

  def campaigns
    if admin_search
      campaign = Campaign.arel_table

      @campaigns ||= Campaign.where(campaign[:demo_id].in(demo_ids_from_explore_tiles).or(campaign[:name].matches("%#{query}%")))
    end
  end

  def organizations
    if admin_search
      @organizations ||= Organization.where(id: organization_ids_from_explore_tiles).all
    end
  end

  def has_results?
    if admin_search
      user_tiles.present? || explore_tiles.present?
    elsif user_search
      user_tiles.present?
    elsif explore_search
      explore_tiles.present?
    end
  end

  private

    def formatted_query
      return '*' if query.blank?

      query
    end

    def default_fields
      ["headline^10", :supporting_content, :tag_titles, :organization_name]
    end

    def default_match
      :word_start
    end

    def demo_id
      demo.id
    end

    def user_tiles_options(tile_status)
      {
        where: {
          demo_id: demo_id,
          status:  tile_status
        },
        fields: default_fields,
        track: search_tracking_data,
        operator: "or",
        misspellings: false
      }
    end

    def explore_tiles_options
      {
        where: {
          is_public: true,
          status: [Tile::ACTIVE, Tile::ARCHIVE]
        },
        fields: default_fields,
        track: search_tracking_data,
        operator: "or",
        misspellings: false
      }
    end

    def unpaginated_user_tiles
      if admin_search
        @unpaginated_user_tiles ||= Tile.search(formatted_query, user_tiles_options([Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE]))
      elsif user_search
        @unpaginated_user_tiles ||= Tile.search(formatted_query, user_tiles_options([Tile::ACTIVE, Tile::ARCHIVE]))
      end
    end

    def unpaginated_explore_tiles
      if explore_search
        @unpaginated_explore_tiles ||= Tile.search(formatted_query, explore_tiles_options)
      end
    end

    def demo_ids_from_explore_tiles
      @demo_ids_from_explore_tiles ||= unpaginated_explore_tiles.map(&:demo_id)
    end

    def organization_ids_from_explore_tiles
      @organization_ids_from_explore_tiles ||= Demo.where(id: demo_ids_from_explore_tiles).pluck(:organization_id)
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
      user_search && user.is_client_admin || user.is_site_admin
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
