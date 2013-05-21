class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    @num_tiles_in_digest_email = @demo.num_tiles_in_digest_email
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
  end

  def new
    @tile = Tile.new
  end

  def create
    @tile = @demo.tiles.build

    if params[:tile].present?
      @tile.image = params[:tile][:image]
      @tile.thumbnail = params[:tile][:image]
      @tile.headline = params[:tile][:headline]
    end

    @tile.position = Tile.next_position(@demo)
    
    if @tile.save
      flash[:success] = "OK, you've created a new tile."
      redirect_to new_client_admin_tile_path
    else
      if @tile.image_file_name.blank?
        @tile.errors.delete(:thumbnail)
      end

      # TODO: validation and ActiveRecord errors are done in a surprisingly
      # bullshit manner in Rails. Surely we can improve on this.
      flash[:failure] = "Sorry, we couldn't save this tile: " + @tile.errors.messages.values.join(", ") + "."
      render "new"
    end
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
