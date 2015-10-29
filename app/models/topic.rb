class Topic < ActiveRecord::Base
  has_many :tile_tags
  validates :name, :uniqueness => true

  # full_topics = {
  #   "Benefits" => ["Health Plan Basics", "Rx Benefits", "Health Care Reform", "Health Care Consumerism", "Dental", "Vision", "Open Enrollment Process", "Decision Support"],
  #   "Compliance" => ["Policy", "Sexual Harassment", "Compliance Form"]
  # }
  def self.make_topics_with_tags full_topics
    full_topics.each do |name, tag_titles|
      topic = find_or_create name
      tag_titles.each do |title|
        tag = TileTag.have_tag(title)
        if tag
          tag.topic = topic
          tag.save
        else
          topic.tile_tags.create(:title => title)
        end
      end
    end
  end

  def self.find_or_create name
    Topic.where(name: name).first || Topic.create(name: name)
  end

  def self.rearrange_by_other
    self.rearrange "Other"
  end

  def self.rearrange last_topic_name
    topics = self.all
    i = topics.index{|t| t.name == last_topic_name}
    if i
      last_topic = topics.delete_at(i)
      topics.push(last_topic)
    end
    topics
  end
end
