class Campaign < ActiveRecord::Base
  before_save :update_slug
  validates :name, uniqueness: true, presence: true

  belongs_to :demo
  acts_as_taggable_on :channels
  
  has_attached_file :cover_image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :alphabetical, -> { order(:name) }

  def to_param
    self.slug
  end

  def update_slug
    self.slug = name.parameterize
  end
end
