class Campaign < ActiveRecord::Base
  belongs_to :demo
  acts_as_taggable_on :channels
  has_attached_file :cover_image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :alphabetical, -> { order(:name) }
end
