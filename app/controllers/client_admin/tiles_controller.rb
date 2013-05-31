class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at  # Demo...
    @tile_digest_email_send_on = @demo.tile_digest_email_send_on  # ...attributes

    @active_tiles  = @demo.active_tiles
    @archive_tiles = @demo.archive_tiles
    @digest_tiles  = @demo.digest_tiles
  end

  def new
    @tile_builder_form = TileBuilderForm.new(@demo)
  end

  def create
    @tile_builder_form = TileBuilderForm.new(@demo, parameters: params[:tile_builder_form])

    if @tile_builder_form.create_objects
      flash[:success] = "OK, you've created a new tile."
      redirect_to new_client_admin_tile_path
    else
      # TODO: validation and ActiveRecord errors are done in a surprisingly
      # bullshit manner in Rails. Surely we can improve on this.
      flash[:failure] = "Sorry, we couldn't save this tile: " + @tile_builder_form.error_messages
      render "new"
    end
  end

  def update
    tile = Tile.find params[:id]

    # Check because figure there will be other entirely-different situations where we are updating a tile...
    if params[:update_status]
      if tile.update_attributes status: params[:update_status]
        flash[:success] = "The #{tile.headline} tile has been archived"
      else
        flash[:failure] = "There was a problem archiving this tile. Please try again."
      end
      redirect_to action: :index
    end
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
