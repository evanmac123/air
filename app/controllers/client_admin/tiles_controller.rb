class ClientAdmin::TilesController < ClientAdminBaseController
  before_filter :get_demo

  def index
    @num_tiles_in_digest_email = @demo.num_tiles_in_digest_email
    @tile_digest_email_sent_at = @demo.tile_digest_email_sent_at
  end

  private

  def get_demo
    @demo = current_user.demo
  end
end
