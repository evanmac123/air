module ClientAdmin::SharesHelper  
  def show_conditionally_invite_users(demo = current_user.demo)
    #TODO auto_show should be removed from user modal
    render 'invite_users', demo: demo
  end
  
  def digest_sent_modal_text digest_type
    if digest_type == "test_digest"
      "A test digest email has been sent to #{current_user.email}. You should receive it shortly."
    else
      "Your Tiles have been successfully sent. New Tiles you post will appear in the email preview."
    end
  end

  def share_tile_by_linkedin(tile)
    params = {
      mini: true,
      url: explore_tile_preview_url(tile),
      title: tile.headline,
      summary: tile.supporting_content,
      source: "http://www.airbo.com"
    }
    "https://www.linkedin.com/shareArticle?#{params.to_query}"
  end

  def sharable_tile_on_linkedin(tile)
    params = {
      mini: true,
      url: sharable_tile_url(tile),
      title: tile.headline,
      summary: tile.supporting_content,
      source: "http://www.airbo.com"
    }
    "https://www.linkedin.com/shareArticle?#{params.to_query}"
  end

  def sharable_tile_on_facebook(tile)
    params = {
      u: sharable_tile_url(tile)
    }
    "http://www.facebook.com/sharer.php?#{params.to_query}"
  end

  def sharable_tile_on_twitter(tile)
    params = {
      url: sharable_tile_url(tile)
    }
    "https://twitter.com/intent/tweet?#{params.to_query}"
  end
end
