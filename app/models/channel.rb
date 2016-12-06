class Channel < ActiveRecord::Base
  before_save :update_slug
  has_attached_file :image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
      path: "channel/:id/:filename",
      bucket: APP_BUCKET
    }.merge(ATTACHMENT_CONFIG_BASE)

  def update_slug
    self.slug = name.parameterize
  end
end
