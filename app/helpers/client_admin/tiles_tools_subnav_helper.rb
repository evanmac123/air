module ClientAdmin::TilesToolsSubnavHelper 
  def tiles_to_be_sent(user)
    demo = user.demo
    demo.digest_tiles(demo.tile_digest_email_sent_at).count
  end
end