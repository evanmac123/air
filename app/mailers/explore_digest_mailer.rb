class ExploreDigestMailer < BaseTilesDigestMailer

  def notify_one(sections, subject, user)
    @user  = user
    return nil unless @user.email.present?

    @presenter = TilesDigestMailExplorePresenter.new(sections, email_attrs, user, custom_from)

    undecorated_tiles = tile_ids.map{|tile_id| Tile.find(tile_id)}

    @tiles = TileExploreDigestDecorator.decorate_collection undecorated_tiles, context: { user: @user, tile_ids: tile_ids }

    ping_on_digest_email(@presenter.email_type, @user, link_subject)

    mail to: @user.email_with_name,
      from: @presenter.from_email,
      subject: subject,
      template_path: 'explore_digest_mailer',
      template_name: 'notify_one'
  end

  def notify_all(sections, email_attrs, users = nil, custom_from = nil)
    users = users || User.where{ (is_client_admin) == true | (is_site_admin == true) }

    users.each { |user|
      ExploreDigestMailer.delay.notify_one(sections, email_attrs, user, custom_from)
    }
  end
end
