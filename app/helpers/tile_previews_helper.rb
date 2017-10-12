module TilePreviewsHelper
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
  #
  def tile_preview_status_change_tooltip tile
    change_statuses = [Tile::DRAFT, Tile::ACTIVE, Tile::ARCHIVE, ].reject{|x|x==tile.status}
    change_statuses = change_statuses.reject{|x|x==Tile::DRAFT} if tile.tile_completions.count > 0
    build_status_change_action_menu tile, change_statuses
  end
  #
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
  #
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

  def share_via_explore(tile)
    render 'client_admin/tiles/tile_preview/public_section', tile: tile
  end

  def share_to_explore_css_config tile
    share_to_explore_classes = %w(share_to_explore button)
    share_to_explore_classes << "remove_from_explore outlined yellow" if tile.is_public

    h = {}

    h[:share_to_explore_classes] = share_to_explore_classes
    h
  end

  def sharable_tile_link tile
    request.host_with_port.gsub(/^www./, "") + sharable_tile_path(tile)
  end

  def display_tile_share_options?(tile)
    tile.is_sharable || params[:controller] == "explore/tile_previews"
  end

  def tile_link_source(tile)
    if params[:controller] == "explore/tile_previews"
      :explore
    else
      :sharable
    end
  end
end
