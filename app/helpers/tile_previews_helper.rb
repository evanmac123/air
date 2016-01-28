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
    author_name << tile.demo.client_name if tile.demo.client_name.present?
    author_name << tile.demo.name

    author_name.join(', ')
  end

  def preview_menu_item_config_by_status status
    {
      draft: {txt: "Draft", icon: "fa-edit", status: "draft", action: "Draft"},
      active: {txt: "Posted", icon: "fa-check", status: "active", action: "Post"}, 
      archive: {txt: "Archived", icon: "fa-archive", status: "archive", action: "Archive"},
      user_submitted: {txt: "Submitted", icon: "fa-archive", status: "Accept", action: "Accept"},
      ignored: {txt: "Ignored", icon: "fa-trash", status:  "ignored", action: "Ignore"}
    }[status.to_sym]
  end

  def suggested_menu_item_config_by_status status
    {
      user_submitted: {txt: "Submitted", icon: "fa-archive", status: "Accept", action: "Accept"},
      ignored: {txt: "Ignored", icon: "fa-trash", status:  "ignored", action: "Ignore"}
    }[status.to_sym]
  end


  def suggested_tile_status_change_tooltip tile 
    build_status_change_action_menu tile, [Tile::USER_SUBMITTED, Tile::IGNORED]
  end

  def tile_preview_status_change_tooltip tile
    change_statuses = [Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE, ].reject{|x|x==tile.status}
    change_statuses = change_statuses.reject{|x|x==Tile::DRAFT} if tile.tile_completions.count > 0
    build_status_change_action_menu tile, change_statuses
  end

  def tile_preview_menu_status_item tile
   build_menu_item_link preview_menu_item_config_by_status(tile.status)
  end


  def suggested_tile_menu_status_item tile
    build_menu_item_link  suggested_menu_item_config_by_status(tile.status)
  end

  def tile_preview_menu_action_item tile, config
    link_to  status_change_client_admin_tile_path(tile), data: {status: config[:status], "tile-id" => tile.id},  class: 'update_status' do
      menu_item_text_and_icon(config[:action], config[:icon])
    end
  end

  def menu_item_text_and_icon txt, icon
    s = content_tag :i,  class: "fa #{icon} fa-1x" do; end
    s+= content_tag :span,  class: "header_text " do
      "#{txt}" 
    end
    s
  end

  def build_menu_item_link config
    content_tag :a do
      menu_item_text_and_icon(config[:txt], config[:icon])
    end
  end

  def build_status_change_action_menu tile, statuses
    content_tag :div, id: "stat_change_sub", class: "preview_menu_item" do
      s=""
      statuses.each do |stat|
        config = preview_menu_item_config_by_status(stat)
        s+= tile_preview_menu_action_item tile, config
      end
      raw s
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
    content_tag :div, class: "share_section" do
      content_tag :div, class: "share_via_block" do
        s =""
        %w(facebook twitter linkedin).each do |site|
          s += tile_preview_menu_social_share tile, site
        end
        s += email_share_link tile
        raw s
      end
    end
  end

  def email_share_link tile
    mail_content = capture do 
      content_tag :div, class: "share_via share_via_email" do
        fa_icon('envelope')
      end
    end
    mail_to "", mail_content, subject: "Tile shared via Airbo", body: " I want to share this tile with you from Airbo: #{sharable_tile_url(tile)}"
  end 

  def tile_share_public_link tile
    content_tag :div, class: "share_via_link" do
      text_field_tag 'sharable_tile_link', sharable_tile_link(tile), disabled: !tile.is_sharable?
    end 
  end

  def tile_share_public_link_block tile
    tooltip = "If tile share link is on, anyone with the link can see the tile."
    content_tag :div, class: "share_section" do
      s= content_tag :div, class: "share_link_block" do
        s1 = content_tag :div, "Tile Share Link", class: "title"
        s1 += content_tag :i, "", class: "fa fa-question-circle has-tip",  data: {tooltip: "true"},  title: tooltip
        s1 += content_tag :div,  class: "tile_status" do
          s2 = content_tag :div, "OFF", class: "off #{tile.is_sharable? ? 'disengaged' : 'engaged'}"
          s2 += tile_share_public_link_form tile
          s2 += content_tag :div, "ON", class: "on #{tile.is_sharable? ? 'engaged' : 'disengaged'} "
          s2
        end
        s1
      end
      s+= tile_share_public_link tile
    end
  end

  def tile_share_public_link_form tile
    s = form_for tile, url: client_admin_sharable_tile_path(tile), method: :put, remote: true, html: { id: "sharable_link_form"} do |form|
      content_tag :div,  class:"switch tiny round" do
        s1 = form.radio_button :is_sharable, true, id: 'sharable_tile_link_on' 
        s1+=  form.radio_button :is_sharable, false, id: 'sharable_tile_link_off'
        s1+=  content_tag :span,"",  class: 'green-paddle'
      end
    end 

    raw s
  end

  def share_via_explore tile
    has_tags_class = tile.tile_tags.present? ? "has_tags" : ""
    s= form_for TilePublicForm.new(tile), url: update_explore_settings_client_admin_tile_path(tile), method: :put, remote: true, html: {id: "public_tile_form"} do |f| 
      render 'client_admin/tiles/tile_preview/public_section', form: f, has_tags_class: has_tags_class
    end 
    raw s
  end

  def share_to_explore_css_config tile 
    copy_switch_classes = %w(switch tiny round allow_copy)

    share_to_explore_classes = %w(share_to_explore)
    share_to_explore_classes << "disabled" unless tile.tile_tags.present?
    share_to_explore_classes << "remove_from_explore" if tile.is_public 

    h = {} 

    h[:copy_switch_classes] = copy_switch_classes
    h[:share_to_explore_classes] = share_to_explore_classes

    #h[:add_tag_class] = tile.tile_tags.present? ? "" : "highlighted"
    h[:share_to_explore_text] = tile.is_public ? "Remove" : "Share"
    h
  end

  def sharable_tile_link tile
    request.host_with_port.gsub(/^www./, "") + sharable_tile_path(tile)
  end


end
