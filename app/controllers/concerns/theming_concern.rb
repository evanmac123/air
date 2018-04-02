# frozen_string_literal: true

module ThemingConcern
  def set_theme
    @palette = current_demo.try(:custom_color_palette)
  end
end
