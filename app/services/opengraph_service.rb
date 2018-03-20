class OpengraphService
  class << self
    def image_for_board(board:)
      tile_to_display = board.tiles.active.first

      if tile_to_display.present?
        tile_to_display.thumbnail.url
      else
        OpengraphService.image
      end
    end

    def image(image_path = nil)
      if image_path
        image_path
      else
        ActionController::Base.helpers.asset_path("marketing_site/airbo-marketing-open-graph.png")
      end
    end

    def title(custom_title = nil)
      if custom_title
        custom_title
      else
        "Airbo"
      end
    end

    def description(description = nil)
      if description
        description
      else
        "Airbo is a simple micro site that's used by HR to drive employee education, appreciation, and participation."
      end
    end
  end
end
