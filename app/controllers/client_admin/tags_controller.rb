class ClientAdmin::TagsController < ClientAdminBaseController
  def create
    tag = TileTag.new(title: params[:tag_name])
    tag.save

    load_tags
    render partial: "client_admin/tiles/tag_select", locals: {tags: @tags, selected_tag_id: tag.id}
  end
end
