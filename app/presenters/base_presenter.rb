# frozen_string_literal: true

class BasePresenter
  def initialize(object, template, options)
    @object = object
    @template = template
    @is_ie = options[:is_ie] || false
  end

  def self.presents(name)
    define_method(name) do
      @object
    end
  end

  def h
    @template
  end

  def from_search?
    false
  end

  def method_missing(*args, &block)
    @template.send(*args, &block)
  end

  def has_ribbon_tag?
    if ribbon_tag = tile.ribbon_tag
      @ribbon_tag_name = ribbon_tag.name
      @ribbon_tag_color = ribbon_tag.color
      true
    else
      false
    end
  end

  def ribbon_tag_name
    @ribbon_tag_name ||= tile.ribbon_tag.name
  end

  def ribbon_tag_color
    @ribbon_tag_color ||= tile.ribbon_tag.color
  end

  def ribbon_tag_font_color
    hex = if @ribbon_tag_color.length == 7
      @ribbon_tag_color[1..-1]
    else
      @ribbon_tag_color[1] + @ribbon_tag_color[1] + @ribbon_tag_color[2] + @ribbon_tag_color[2] + @ribbon_tag_color[3] + @ribbon_tag_color[3]
    end
    red = Integer(hex[0..1], 16)
    green = Integer(hex[2..3], 16)
    blue = Integer(hex[4..5], 16)
    (red * 0.299 + green * 0.587 + blue * 0.114) > 186 ? "#000000" : "#FFFFFF"
  end
end
