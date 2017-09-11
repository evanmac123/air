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

    def default_image
      ActionController::Base.helpers.asset_path("marketing_site/airbo-marketing-open-graph.png")
    end

    def title(custom_title)
      if custom_title.present?
        custom_title
      else
        "Airbo"
      end
    end

    def default_description
      "Airbo is a simple micro site that's used by HR to drive employee education, appreciation, and participation."
    end
  end
end
