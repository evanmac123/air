class AirboSearch
  PER_PAGE = 8.freeze

  attr_accessor :query, :user, :demo, :options

  # @user_tiles = service.user_tiles(params[:user_tiles_page])
  # @explore_tiles = service.explore_tiles(params[:explore_tiles_page])
  #
  # @campaigns = service.campaigns
  # @organizations = service.organizations

  def initialize(query, user, options)
    @query = query
    @user = user
    @demo = get_demo
    @options = options

    load_records!(records_to_load)
  end

  def user_tiles
    unpaginated_user_tiles.records.page(options[:page]).per(per_page)
  end

  def explore_tiles
    if explore_search
      unpaginated_explore_tiles.records.page(options[:page]).per(per_page)
    end
  end

  def campaigns
    if admin_search
      @campaigns ||= Campaign.where(demo_id: demo_ids_from_explore_tiles).all
    end
  end

  def organizations
    if admin_search
      @organizations ||= Organization.where(id: organization_ids_from_explore_tiles).all
    end
  end

  private

    def records_to_load
      options[:records_to_load] || :all
    end

    def load_records!(records_to_load)
      if records_to_load == :all
        load_all_records
      else
        send(records_to_load)
      end
    end

    def formatted_query
      return '*' if query.blank?

      query
    end

    def default_fields
      [:headline, :supporting_content, :tag_titles]
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
        match: default_match,
        operator: 'or',
        order: {_score: :desc}
      }
    end

    def explore_tiles_options
      {
        where: {
          is_public: true,
          status: [Tile::ACTIVE, Tile::ARCHIVE]
        },
        fields: default_fields,
        match: default_match,
        operator: 'or',
        order: {_score: :desc}
      }
    end

    def load_all_records
      unpaginated_user_tiles
      unpaginated_explore_tiles
      campaigns
      organizations
    end

    def unpaginated_user_tiles
      if admin_search
        @unpaginated_user_tiles ||= Tile.search(formatted_query, user_tiles_options(["draft", "active", "archive"]))
      elsif user_search
        @unpaginated_user_tiles ||= Tile.search(formatted_query, user_tiles_options(["active", "archive"]))
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
      options[:per_page] || PER_PAGE
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
end
