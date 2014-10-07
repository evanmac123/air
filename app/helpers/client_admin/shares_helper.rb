module ClientAdmin::SharesHelper  
  def show_conditionally_invite_users(demo = current_user.demo)
    #TODO auto_show should be removed from user modal
    render 'invite_users', demo: demo
  end
  
  def show_linkein_share(demo)
    params = {
      mini: true,
      url: public_board_url(demo.public_slug),
      title: demo.name,
      summary: '',
      source: '', 
      class: 'share linkedin'          
    }
    link_to fa_icon('linkedin-square 2x'), "https://www.linkedin.com/shareArticle?#{params.to_query}", target: '_blank'
  end

  def share_tile_by_linkedin(tile)
    params = {
      mini: true,
      url: explore_tile_preview_url(tile),
      title: tile.headline,
      summary: tile.supporting_content,
      source: "http://www.air.bo"
    }
    "https://www.linkedin.com/shareArticle?#{params.to_query}"
  end

  def show_facebook_share(demo)
    link_to fa_icon('facebook-square 2x'), "https://www.facebook.com/sharer/sharer.php?u=#{public_board_url(demo.public_slug)}", class: 'share facebook', target: '_blank'
  end

  def show_twitter_share(demo)
    link_to fa_icon('twitter 2x'), "https://twitter.com/home?status=Come check out my new @theairbo board: #{public_board_url(demo.public_slug)}", class: 'share twitter', target: '_blank', id: 'share_twitter'
  end

  def sharable_tile_on_linkedin(tile)
    params = {
      mini: true,
      url: sharable_tile_url(tile),
      title: tile.headline,
      summary: tile.supporting_content,
      source: "http://www.air.bo"
    }
    "https://www.linkedin.com/shareArticle?#{params.to_query}"
  end

  def sharable_tile_on_facebook(tile)
    params = {
      u: sharable_tile_url(tile)
    }
    "http://www.facebook.com/sharer.php?#{params.to_query}"
  end
end
