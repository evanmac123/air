class TileStatusChangeManager

  def initialize tile
		@tile = tile
		@demo_id = tile.demo.id
		@user_id = tile.original_creator.id
	end


  def process
		if tile_approved 
			send_acceptance_email
		end
	end
    
	private


  def send_acceptance_email
		SuggestedTileStatusMailer.delay.accepted(@demo_id,@user_id,@user_id)
	end


	def tile_approved
		[Tile::USER_SUBMITTED, Tile::DRAFT] == @tile.changes[:status]
	end

end
