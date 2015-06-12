class TileStatusChangeManager

  def initialize tile
		@tile = tile

	end


  def process
		if tile_approved 
			send_acceptance_email
		end
	end
    
	private


  def send_acceptance_email
   TileAc 
	end


	def tile_approved
		[Tile::USER_SUBMITTED, Tile::DRAFT] == @tile.changes[:status]
	end

end
