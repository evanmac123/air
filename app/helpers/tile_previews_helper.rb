module TilePreviewsHelper
  def get_tile_likes(tile, current_user)
    tile.like_count
  end

  def show_tile_likes(tile, current_user)
    if tile.like_count < 1
      "Be the first person to like this tile"
    elsif tile.like_count < 2
      if current_user.likes_tile?(tile)
        "Liked by you"
      else
        "Liked by #{tile.user_tile_likes.last.user.name}"
      end
    elsif tile.like_count == 2
      if current_user.likes_tile?(tile)
        "Liked by you and #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name}"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "Liked by #{user_tile_likes[0].user.name} and #{user_tile_likes[1].user.name}"
      end
    else #count is greater than 3
      if current_user.likes_tile?(tile)
        "Liked by you, #{tile.user_tile_likes.where('user_id <> ?', current_user.id).last.
        user.name}, and #{pluralize(tile.like_count - 2, 'other')}"
      else
        user_tile_likes = tile.user_tile_likes.limit(2).order('created_at DESC')       
        "Liked by #{user_tile_likes[0].user.name}, #{user_tile_likes[1].user.name}, and #{pluralize(tile.like_count - 2, 'other')}"
      end
    end
  end

  def show_company_and_demo(tile)
    author_name = []

    #author_name << tile.creator.name if tile.creator
    author_name << tile.demo.client_name if tile.demo.client_name.present?
    author_name << tile.demo.name

    author_name.join(', ')
  end

  def draft_menu_item_config type
    if type == :action
      ["Post",  "fa-check", "active"]
    else
      ["Draft", "fa-edit"]
    end
  end

  def active_menu_item_config type
    if type == :action
      [ "Archive", "fa-archive", "archive"]
    else
      ["Posted", "fa-archive" ]
    end
  end

  def archive_menu_item_config type
    if type == :action
      ["Repost", "fa-check", "active"]
    else
      ["Archived", "fa-archive"]
    end
  end

  def preview_menu_item_config_by_status status, type
    keys = [:txt,  :icon,  :status]
    values = case status
             when Tile::DRAFT
               draft_menu_item_config type
             when Tile::ARCHIVE
               archive_menu_item_config type
             when Tile::ACTIVE
               active_menu_item_config type
             end

    Hash[keys.zip(values)]
  end

  def menu_item_text_and_icon txt, icon
    s = content_tag :i,  class: "fa #{icon} fa-1x" do; end
    s+= content_tag :span,  class: "header_text " do
      "#{txt}" 
    end
    s
  end

  def tile_preview_menu_item_config tile, opts
    config = {status: tile.status }.merge(opts)
    config.merge! (preview_menu_item_config_by_status config[:status], :action)
  end

  def tile_preview_status_change_tooltip tile
    change_statuses = [Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE].reject{|x|x==tile.status}

    content_tag :div, id: "stat_change_sub" do
      s=""
      change_statuses.each do |stat|
       s+= content_tag :p do
           tile_preview_menu_action_item tile, {status: stat }
        end
      end
      raw s
    end
  end


  def tile_preview_menu_status_item tile 
    config = preview_menu_item_config_by_status tile.status, :status
    content_tag :a do
      menu_item_text_and_icon(config[:txt], config[:icon])
    end
  end

  def tile_preview_menu_action_item tile, opts={}
    config = tile_preview_menu_item_config tile, opts
    link_to  status_change_client_admin_tile_path(tile), data: {status: config[:status]},  class: 'update_status' do
      menu_item_text_and_icon(config[:txt], config[:icon])
    end
  end

  def tile_preview_menu_social_share tile, site
    site_link = "sharable_tile_on_#{site}".to_sym
    link_to send(site_link, tile) do 
      content_tag :div, class: "share_via share_via_#{site}" do
        fa_icon(site, class: "1x")
      end 
    end
  end

  def social_share_links tile
    content_tag :div, id: "social_share" do
      s =""
      %w(facebook twitter linkedin).each do |site|
        s += tile_preview_menu_social_share tile, site
      end
      raw s
    end
  end

  def share_via_explore tile
    s= form_for TilePublicForm.new(tile), url: client_admin_public_tile_path(tile), method: :put, html: {id: "public_tile_form"} do |f| 
      render 'client_admin/tiles/tile_preview/public_section', form: f
    end 
    raw s
  end

  def share_to_explore_css_config tile 
    copy_switch_classes = %w(switch small round allow_copy)
    copy_switch_classes << "disabled" unless tile.tile_tags.present?

    share_to_explore_classes = %w(share_to_explore)
    share_to_explore_classes << "disabled" unless tile.tile_tags.present?
    share_to_explore_classes << "remove_from_explore" if tile.is_public 

    h = {} 

    h[:copy_switch_classes] = copy_switch_classes
    h[:share_to_explore_classes] = share_to_explore_classes

    h[:add_tag_class] = tile.tile_tags.present? ? "" : "highlighted"
    h[:share_to_explore_text] = tile.is_public ? "Remove from Explore" : "Share to Explore"
    h
  end

  def sharable_tile_link tile
    request.host_with_port.gsub(/^www./, "") + sharable_tile_path(tile)
  end


end
