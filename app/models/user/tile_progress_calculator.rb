class User
	class TileProgressCalculator
		def initialize(user)
			@user = user
		end


		def available_tiles_on_current_demo
			available_differs_from_completed?
			if available_differs_from_completed?
				 @available_active -= tiles_not_used_in_tile_progress
			end
			@available_active
		end

		def completed_tiles_on_current_demo
			if available_differs_from_completed?
				@completed_active -= tiles_not_used_in_tile_progress
			end
			@completed_active
		end

		def tiles_not_used_in_tile_progress
			@res ||= Tile.joins(:tile_completions).
				where do 
				(status == Tile::ACTIVE) & 
					(tile_completions.user_id == @user.id) & 
					(tile_completions.not_show_in_tile_progress == true) & 
					(demo_id == @user.demo_id) 
			end
		end


		def available_differs_from_completed?
			@res ||= (available_ids.sort != completed_ids.sort)
		end

		def available_ids
			@available_ids ||= self.available.pluck(:id)
		end

		def completed_ids
			@completed_ids ||= self.completed.pluck(:id)
		end


		def available
			@available_active ||= @user.demo.tiles.where(status: Tile::ACTIVE)
		end

		def completed
			@completed_active ||= @user.completed_tiles.where(demo_id: @user.demo, status: Tile::ACTIVE)
		end

		def not_show_all_completed_tiles_in_progress
			userid = @user.id
			tile_demo_id = @user.demo_id
			completed_tiles = TileCompletion.joins(:tile).
				where do 
				(tile.status == Tile::ACTIVE) & 
					(user_id == userid) & 
					(not_show_in_tile_progress == false) & 
					(tile.demo_id == tile_demo_id) 
			end
			completed_tiles.update_all(not_show_in_tile_progress: true)
		end
	end
end
