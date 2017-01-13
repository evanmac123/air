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

  private

  def formatted_query
    return '*' if query.blank?

    query
  end

  def default_fields
    [:header, :supporting_content]
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

end
