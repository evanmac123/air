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
    params[:term].strip.gsub(/\s+/, ' ').split.map(&:capitalize).join(' ')
  end
  
  def search_results_as_json
    normalized_tag = normalized_title
    tags = name_like(normalized_tag).order(:title).limit(10)

    if tags.empty?
      add_tag_json(normalized_tag)
    else
      tags.map{|tag| search_result(tag)}.to_json
    end
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

  def add_tag_json(normalized_title)
    label = ERB::Util.h(%{Tag doesn't exist. Click to add.})
    [{
        label: label,
        value: {
          found: false,
          name: normalized_title,
          url:   add_client_admin_tile_tags_url(normalized_title)
        }
      }].to_json
  end
  
  def name_like(text)
    TileTag.where("title ILIKE ?", "%#{text}%")  
  end
end
