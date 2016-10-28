class Topic < ActiveRecord::Base
  has_many :tile_tags
  has_one :reference_board, class_name: TopicBoard,  foreign_key: :topic_id, conditions:{is_reference: true}
  has_many :topic_boards
  has_many :boards, through: :topic_boards, class_name: Demo
  scope :is_explore, -> { where is_explore: true }
  has_attached_file :cover_image,
    {
      styles: { medium: "300x200>", thumb: "100x100>" },
      default_style: :medium,
      default_url: "assets/images/airbo_venice.png",
      bucket: S3_LOGO_BUCKET
    }.merge(TOPIC_OPTIONS)

  validates_attachment_content_type :cover_image, content_type: /\Aimage\/.*\z/

  validates :name, uniqueness: true, presence: true
  validates :cover_image, presence: true

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
