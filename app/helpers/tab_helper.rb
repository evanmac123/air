module TabHelper
  def tab(text, path, active_text)
    content_tag 'li', {:class => (text == active_text ? "active" : nil)} do
      link_to text, path
    end
  end
end
