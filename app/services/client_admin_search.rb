class ClientAdminSearch
  attr_accessor :query, :demo

  def initialize(query, demo)
    self.query = query
    self.demo = demo
  end

  def my_tiles
    @my_tiles ||= Tile.search(formatted_query, my_tiles_options)
  end

  def explore_tiles
    @explore_tiles ||= Tile.search(formatted_query, explore_tiles_options)
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
    [:header, :supporting_content, :tag_titles]
  end

  def demo_id
    demo.id
  end

  def my_tiles_options
    {
      where: {
        demo_id: demo_id
      },
      fields: default_fields
    }
  end

  def explore_tiles_options
    {
      where: {
        is_public: true,
        status: [Tile::ACTIVE, Tile::ARCHIVE]
      },
      fields: default_fields
    }
  end

  def demo_ids_from_explore_tiles
    @demo_ids_from_explore_tiles ||= explore_tiles.map(&:demo_id)
  end


  def organization_ids_from_explore_tiles
    @organization_ids_from_explore_tiles ||= Demo.where(id: demo_ids_from_explore_tiles).pluck(:organization_id)
  end

end
