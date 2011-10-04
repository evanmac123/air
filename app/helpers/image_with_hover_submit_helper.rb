module ImageWithHoverSubmitHelper
  def image_with_hover_submit_tag(src, selector, options={})
    clipped_src = src.gsub(/\.png$/, '')
    hover_src = clipped_src + '_hover.png'

    normal_tag = image_submit_tag src, options
    hover_preload = image_tag hover_src, :style => 'display: none'

    content_for :javascript do
      javascript_tag <<-END_HOVER_JS
        $(document).ready(function() {
          $('#{selector}').hover(
            function() {
              $(this).attr('src', '#{image_path(hover_src)}');
            },

            function() {
              $(this).attr('src', '#{image_path(src)}');
            }
          )
        });
      END_HOVER_JS
    end

    raw (normal_tag + hover_preload)
  end
end
