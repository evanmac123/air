module SkinHelper
  # Broken up into 2 parts because 'skinned_for_demo' is used in emails which have no "current_user"
  def skinned(key, default)
    skinned_for_demo(current_user.demo, key, default)
  end

  def skinned_for_demo(demo, key, default)
    skin = demo.skin
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
