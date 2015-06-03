class TilesDigestMailer < BaseTilesDigestMailer

	def notify_one(demo_id, user_id, tile_ids, subject, follow_up_email,
								 custom_headline, custom_message, custom_from=nil, is_new_invite = nil)

    @user  = User.find user_id # XTR
    return nil unless @user.email.present? 

    @tile_ids = tile_ids
    @demo = Demo.find demo_id


    presenter_class = follow_up_email ? TilesDigestMailFollowupPresenter : TilesDigestMailDigestPresenter
    @presenter = presenter_class.new(@user, @demo, custom_from, custom_headline, custom_message, is_new_invite)


		@tiles = TileBoardDigestDecorator.decorate_collection(
			tiles_by_position,  
			context: { demo: @demo, user: @user, follow_up_email: @follow_up_email, email_type:  @presenter.email_type }
		)     

    ping_on_digest_email  @presenter.email_type, @user
    mail  to: @user.email_with_name, from: @presenter.from_email, subject: subject 
	end

  def notify_one_explore  user_id, tile_ids, subject, email_heading, custom_message, custom_from=nil
    @user  = User.find user_id
    return nil unless @user.email.present? 

    @presenter = TilesDigestMailExplorePresenter.new(custom_from, custom_message, email_heading, @user.explore_token)

    undecorated_tiles = tile_ids.map{|tile_id| Tile.find(tile_id)}

    @tiles = TileExploreDigestDecorator.decorate_collection undecorated_tiles, context: { user: @user }

    ping_on_digest_email(@presenter.email_type, @user)

		mail to: @user.email_with_name, 
			from: @presenter.from_email, 
			subject: subject, 
			template_path: 'tiles_digest_mailer', 
			template_name: 'notify_one'
  end

	def notify_all_follow_up_from_delayed_job
		FollowUpDigestEmail.send_follow_up_digest_email.each do |followup| 
			TilesDigestMailer.delay(run_at: noon).notify_all_follow_up(followup.id) 
		end	
	end

	def notify_all(demo, unclaimed_users_also_get_digest, tile_ids, custom_headline, custom_message, subject)
		user_ids = demo.users_for_digest(unclaimed_users_also_get_digest).pluck(:id)

		user_ids.reject! do |user_id| 
			BoardMembership.where(demo_id: demo.id, user_id: user_id, digest_muted: true).first.present? 
		end

		user_ids.each do |user_id| 
			TilesDigestMailer.delay.notify_one(demo.id, user_id, tile_ids, subject, false, custom_headline, custom_message) 
		end 
	end

	def notify_all_follow_up(followup_id)
		followup = FollowUpDigestEmail.find followup_id
		subject = if followup.original_digest_subject.present?
								"Don't Miss: #{followup.original_digest_subject}"              
							else
								"Don't Miss Your New Tiles"              
							end
		headline = followup.original_digest_headline

		tile_ids = followup.tile_ids
		user_ids = followup.demo.users_for_digest(followup.unclaimed_users_also_get_digest).where(id: followup.user_ids_to_deliver_to).pluck(:id)

		user_ids.reject! { |user_id| TileCompletion.user_completed_any_tiles?(user_id, tile_ids)}
		user_ids.reject! { |user_id| BoardMembership.where(demo_id: followup.demo_id, user_id: user_id, followup_muted: true).first.present? }
		user_ids.each    { |user_id| TilesDigestMailer.delay.notify_one(followup.demo.id, user_id, tile_ids, subject, true, headline, nil) }

		followup.destroy
	end

	def notify_all_explore tile_ids, subject, email_heading, custom_message, custom_from=nil
		user_ids = User.where{ (is_client_admin) == true | (is_site_admin == true) }
		user_ids.each{ |user_id| TilesDigestMailer.delay.notify_one_explore(user_id, tile_ids, subject, email_heading, custom_message, custom_from=nil) }
	end


end
