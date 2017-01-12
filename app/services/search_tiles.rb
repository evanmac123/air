class SearchTiles
  attr_accessor :query, :organization, :custom_options

  def initialize(query = nil, organization = nil, custom_options = {})
    self.query = query
    self.organization = organization
    self.custom_options = custom_options
  end

  def tiles
    @tiles ||= Tile.search(formatted_query, options)
  end

  private

  def formatted_query
    return '*' if query.blank?

    query
  end

  def options
    default_options.deep_merge(custom_options)
  end

  def default_options
    {
      where: default_where,
      fields: default_fields
    }
  end

  def default_where
    {
      status: default_status,
      demo_ids: default_demo_ids # method for searching tiles inside of org
    }.delete_if { |k,v| v.nil? }
  end

  def default_fields
    [:header, :supporting_content]
  end

  def default_status
    [
      Tile::ACTIVE,
      Tile::ARCHIVE
    ]
  end

  def default_demo_ids
    return nil if organization.blank?

    organization.demos.pluck(:id)
  end

end
