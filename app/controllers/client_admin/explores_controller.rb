class ClientAdmin::ExploresController < ClientAdminBaseController  
  def show
    @demo = current_user.demo
    @tiles_to_be_sent = @demo.digest_tiles(@demo.tile_digest_email_sent_at).count
  end
end
