class OpengraphService
  class << self
    def image_for_board(board:)
      tile_to_display = board.tiles.active.first

      if tile_to_display.present?
        tile_to_display.image
      else
        OpengraphService.default_image
      end
    end

    def image(image_path)
      if image_path.present?
        image_path
      else
        ActionController::Base.helpers.asset_path("marketing_site/airbo-marketing-open-graph.png")
      end
    end

    def title(custom_title)
      if custom_title.present?
        custom_title
      else
        "Airbo"
      end
    end

    def description(description)
      if description.present?
        description
      else
        "Airbo is a simple micro site that's used by HR to drive employee education, appreciation, and participation."
      end
    end
  end
end
