module SkinHelper
  def skinned(key, default)
    skin = current_user.try(:demo).try(:skin)
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
end
