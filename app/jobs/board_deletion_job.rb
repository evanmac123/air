class BoardDeletionJob

  def initialize board_id
    @demo_id = board_id
  end

  def perform
   BoardMembership.where(demo_id: @demo_id).delete_all
   Tile.where(demo_id: @demo_id).delete_all
   GuestUser.where(demo_id: @demo_id).delete_all
   PotentialUser.where(demo_id: @demo_id).delete_all
   Characteristic.where(demo_id: @demo_id).delete_all
   Act.where(demo_id: @demo_id).delete_all
   FollowUpDigestEmail.where(demo_id: @demo_id).delete_all
   PeerInvitation.where(demo_id: @demo_id).delete_all
   PushMessage.where(demo_id: @demo_id).delete_all
  end

  def nullify_shared_objects
    #NOT Implemented
  end

  def  tile_ids
    #NOTE  Store these tile_ids in case we need to nullify completions
    # and viewings.
    @tile_ids = Tile.where(demo_id: @demo_id).pluck(:id)
  end

  handle_asynchronously :perform
end
