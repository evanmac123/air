module BoardsHelper
  include ActionView::Helpers::TextHelper

  def truncate_name_for_switcher(name)
    truncate name, length: 15
  end

  def creation_source_creator params
    if params[:controller] == "tile_previews"
      "Explore"
    elsif params[:controller] == "pages"
      if params[:action] == "product"
        "Marketing page - Product"
      else
        "Marketing page - Landing"
      end
    else
      ""
    end
  end

  def sign_in_form_page_name params
    if params[:controller] == "tile_previews"
      "explore"
    elsif params[:controller] == "pages"
      if params[:action] == "product"
        "product"
      else
        "welcome"
      end
    else
      ""
    end
  end
end
