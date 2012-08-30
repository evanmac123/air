module EmailInterpolations
  module SelfClosingTag
    def interpolate_self_closing_tag(tag_name, text_to_interpolate, text)
      text.gsub(/\[#{tag_name}\]/, text_to_interpolate)
    end
  end
end
