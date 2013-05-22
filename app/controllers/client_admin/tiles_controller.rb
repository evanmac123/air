class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at  # Demo...
    @tile_digest_email_send_on = @demo.tile_digest_email_send_on  # ...attributes

    @num_tiles_in_digest_email = @demo.num_tiles_in_digest_email
  end

  def new
    @tile = Tile.new
  end

  def create
    @tile = Tile.client_admin_create(@demo, params[:tile])
    
    if @tile.persisted?
      flash[:success] = "OK, you've created a new tile."
      redirect_to new_client_admin_tile_path
    else
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
