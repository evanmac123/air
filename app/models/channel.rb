class Channel < ActiveRecord::Base
  before_save :update_slug

  has_attached_file :image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

  scope :active, -> { where(active: true) }

  def update_slug
    self.slug = name.parameterize
  end

  def tiles
    @tiles ||= Tile.copyable.tagged_with(self.name).uniq
  end
end
