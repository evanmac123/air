module PagesHelper
  def back_to_top_link
    link_to(
      image_tag("new_marketing/img_back_to_top.png"),
      "#home",
      :class => "nav back-to-top-link"
    )
  end
end
