module PagesHelper
  def next_section_link(target)
    link_to(
      image_tag("new_marketing/circle_big.png"),
      "##{target}",
      :class => "nav next-section-link"
    )
  end
end
