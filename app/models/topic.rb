class Topic < ActiveRecord::Base
  has_many :tile_tags

  # full_topics = {
  #   "Benefits" => ["Health Plan Basics", "Rx Benefits", "Health Care Reform", "Health Care Consumerism", "Dental", "Vision", "Open Enrollment Process", "Decision Support"],
  #   "Compliance" => ["Policy", "Sexual Harassment", "Compliance Form"]
  # }
  def make_topics_with_tags full_topics
    full_topics.each do |name, tag_titles|
      topic = find_or_create name
      tag_titles.each do |title|
        tag = TileTag.have_tag(title) || TileTag.create(title: title)
        topic.tile_tags.push(tag)
      end
    end
  end

  def find_or_create name
    Topic.where(name: name).first || Topic.create(name: name)
  end
end
