module SkinHelper
  def skinned(key, default)
    skin = current_user.demo.skin
    if skin && skin[key].present?
      skin[key]
    else
      default
    end
  end

  def css_style(selector, value)
    "#{selector} {#{value} !important}"
  end

  def skin_value(skin_key, skin)
    return nil unless skin && (style = skin[skin_key])
    style
  end

  def background_url_skin_style(selector, skin_key, skin)
    return "" unless (url = skin_value(skin_key, skin))
    css_style(selector, "background: url('#{url}')")
  end

  def background_color_skin_style(selector, skin_key, skin)
    return "" unless (color = skin_value(skin_key, skin))
    css_style(selector, "background-color: ##{color}")
  end

  def color_skin_style(selector, skin_key, skin)
    return "" unless (color = skin_value(skin_key, skin))
    css_style(selector, "color: ##{color}")
  end

  def see_more_button_skinned
    skinned("see_more_button_url", "new_activity/btn_seemore.png")
  end

  def save_button_skinned
    skinned("save_button_url", "new_activity/btn_save.png")
  end

  def fan_button_skinned
    skinned("fan_button_url", "new_activity/btn_beafan.png")
  end

  def defan_button_skinned
    skinned("defan_button_url", "new_activity/btn_defan.png")
  end
end
