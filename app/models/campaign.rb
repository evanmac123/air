class Campaign < ActiveRecord::Base
  belongs_to :demo
  acts_as_taggable
  acts_as_taggable_on :channel_tags
  has_attached_file :cover_image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :alphabetical, -> { order(:name) }
end
