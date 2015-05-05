class TileCreationPlaceholder
  def initialize(path_to_creation_form = nil)
    @path_to_creation_form = path_to_creation_form || Rails.application.routes.url_helpers.new_client_admin_tile_path(path: :via_index)
  end

  def is_placeholder?
    true
  end

  attr_reader :path_to_creation_form
end
