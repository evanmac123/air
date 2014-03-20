class ClientAdmin::TagsController < ClientAdminBaseController
  def create
    normalized_title = params[:tag_name].strip.capitalize.gsub(/\s+/, ' ')

    tag = TileTag.find_or_create_by_title(normalized_title)

    load_tags
    render json: {
      new_list_html: (render_to_string partial: "client_admin/tiles/tag_select", locals: {tags: @tags, selected_tag_id: tag.id})
    }
  end
end
