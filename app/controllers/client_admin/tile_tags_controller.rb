class ClientAdmin::TileTagsController < ClientAdminBaseController
  # TODO: this controller is awful.  Rewrite completely.
  def index
    respond_to do |format|
      @tags = ActsAsTaggableOn::Tag.order(:name)
      format.js do
        render inline: search_results_as_json
      end
    end
  end

  private

    def normalized_title
      params[:term].strip.gsub(/\s+/, ' ')
    end

    def search_results_as_json
      tags = search(normalized_title).order(:name).limit(10)
      result = tags.map { |tag| search_result(tag) }
      result += add_tag(normalized_title)

      result.to_json
    end

    def search_result(tag)
      {
        label: ERB::Util.h(tag.name),
        value: {
          name: tag.name,
          found: true,
        }
      }
    end

    def add_tag(normalized_title)
      label = ERB::Util.h(%{Add new tag})
      [{
          label: label,
          value: {
            found: false,
            name: normalized_title,
            url:   add_client_admin_tile_tags_url(normalized_title)
          }
        }]
    end

    def search(tag)
      @tags.where("name ILIKE ?", "%#{tag}%")
    end
end
