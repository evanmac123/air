module BoardsHelper
  include ActionView::Helpers::TextHelper

  def creation_source params
    if params[:controller] == "explore/tile_previews"
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

  def sign_up_form_page_name params
    if params[:controller] == "explore/tile_previews"
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

  def invite_friends_placeholder
    "Type Name" + (current_user.demo.is_public? ? " or Email" : "")
  end

  def brake_to_paragraphs str
    str.split(/\n/).map{|line| "<p>" + line + "</p>"}.join
  end

  def board_characteristics_for_dom
    current_board.characteristics.map do |characteristic|
      if characteristic.datatype == Characteristic::BooleanType
        {
          id: characteristic.id,
          name: characteristic.name
        }
      end
    end.compact.to_json
  end
end
