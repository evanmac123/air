module ClientAdmin::SharesHelper  
  def show_conditionally_invite_users(demo = current_user.demo)
    #TODO auto_show should be removed from user modal
    render 'invite_users', demo: demo#, auto_show: current_user.show_invite_users_modal? && demo.active_tiles.count > 0
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
    link_to fa_icon('linkedin-square 2x'), "https://www.linkedin.com/shareArticle?#{params.to_query}"    
  end
  def show_facebook_share(demo)
    link_to fa_icon('facebook-square 2x'), "https://www.facebook.com/sharer/sharer.php?u=#{public_board_url(demo.public_slug)}", class: 'share facebook'
  end
  def show_twitter_share(demo)
    link_to fa_icon('twitter 2x'), "https://twitter.com/home?status=#{public_board_url(demo.public_slug)}", class: 'share twitter'
  end
end
