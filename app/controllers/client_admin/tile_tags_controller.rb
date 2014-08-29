class ClientAdmin::TileTagsController < ClientAdminBaseController
  def index
    respond_to do |format|
      @tags = TileTag.order(:title)
      format.js do
        render :inline => search_results_as_json
      end
    end
  end

  def add
    tag = TileTag.find_or_create_by_title(normalized_title)
    render :json => tag.id
  end
    
  protected

  def normalized_title
    params[:term].strip.gsub(/\s+/, ' ')
  end
  
  def search_results_as_json
    tags = TileTag.tag_name_like(normalized_title).order(:title).limit(10)

    result = tags.map{|tag| search_result(tag)}
    if tags.empty? || TileTag.have_tag(normalized_title).empty?
      result += add_tag(normalized_title) 
    end
    result.to_json
  end

  def search_result(tag)
    {
      label: ERB::Util.h(tag.title), 
      value: {
        id: tag.id,
        found: true,
      }
    } 
  end

  def add_tag(normalized_title)
    label = ERB::Util.h(%{Tag doesn't exist. Click to add.})
    [{
        label: label,
        value: {
          found: false,
          name: normalized_title,
          url:   add_client_admin_tile_tags_url(normalized_title)
        }
      }]
  end
end
