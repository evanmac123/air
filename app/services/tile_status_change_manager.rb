class TileStatusChangeManager

  def initialize tile
		@tile = tile
	end


  def process
		if tile_approved?
			send_acceptance_email
		end
	end
    
	private


  def send_acceptance_email
		SuggestedTileStatusMailer.delay.accepted(@tile.demo.id,@tile.original_creator.id,@tile.id)
	end


	def tile_approved?
		@tile.original_creator && [Tile::USER_SUBMITTED, Tile::DRAFT] == @tile.changes[:status]
	end

end
