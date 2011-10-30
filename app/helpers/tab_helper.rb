module TabHelper
  def tab(text, path, active_text, html_options={})
    content_tag 'li', {:class => (text == active_text ? "active" : nil)}.merge(html_options) do
      link_to text, path
    end
  end
end
