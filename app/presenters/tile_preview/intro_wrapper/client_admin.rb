module TilePreview
  module IntroWrapper
    class ClientAdmin
      def initialize(contents)
        @contents = contents
      end

      def to_partial_path
        'client_admin/tiles/tile_preview/intro_wrapper'      
      end

      def locals
        {
          contents: @contents
        }
      end
    end
  end
end
