class ClientAdminSearch
  PER_PAGE = 8.freeze

  attr_accessor :query, :demo, :options

  def initialize(query, demo, options = {})
    self.query = query
    self.demo = demo
    self.options = options
  end

  def my_tiles(page=1)
    unpaginated_my_tiles.records.page(page).per(per_page)
  end

  def explore_tiles(page=1)
    unpaginated_explore_tiles.records.page(page).per(per_page)
  end

  def campaigns
    @campaigns ||= Campaign.where(demo_id: demo_ids_from_explore_tiles).all
  end

  def organizations
    @organizations ||= Organization.where(id: organization_ids_from_explore_tiles).all
  end

  private

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

  def my_tiles_options
    {
      where: {
        demo_id: demo_id
      },
      fields: default_fields, 
      match: default_match,
      operator: 'or'
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
      operator: 'or'
    }
  end

  def unpaginated_my_tiles
    @unpaginated_my_tiles ||= Tile.search(formatted_query, my_tiles_options)
  end

  def unpaginated_explore_tiles
    @unpaginated_explore_tiles ||= Tile.search(formatted_query, explore_tiles_options)
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

end
