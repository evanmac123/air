class SuggestedTileStatusMailer < ActionMailer::Base
	ACCEPTED="Your Tile Has Been Accepted!"
	POSTED="Your Tile Has Been Posted!"
	ARCHIVED="Your Tile Has Been Archived"

	has_delay_mail
	layout "mailer"
	helper :email
		
	def accepted(demo_id, user_id, tile_id)
		set_vars(demo_id, user_id, tile_id, 
						 ACCEPTED, 
						 "The administrator has reviewed your Tile and accepted it. We’ll let you know when it’s posted.") 
		sendit
  end


	def posted(demo_id, user_id, tile_id)
		set_vars(demo_id, user_id, tile_id, 
						POSTED,
						 "The administrator has posted your Tile. You can see how many people have viewed and completed the Tile" ) 
		sendit
	end

	def archived(demo_id, user_id, tile_id)
		set_vars(demo_id, user_id, tile_id, 
						 ARCHIVED, 
						 "The administrator has taken your Tile down from the Board. You can see the total number of people that have viewed and completed the Tile.") 
		sendit
	end

	private

  def set_vars demo_id, user_id, tile_id, subject, sub_header=""
		@user  = User.find user_id
		@tile = Tile.find(tile_id)
		@demo = Demo.find demo_id
		@subject = subject
		@subhead_text = sub_header
		@link = suggested_tiles_url
	end	

	def sendit
		mail to: @user.email_with_name, from: @demo.reply_email_address, subject: @subject
	end

end
