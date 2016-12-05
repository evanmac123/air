class Channel < ActiveRecord::Base
  attr_accessible :image, :name

  has_attached_file :cover_image,
    {
      styles: { explore: "167x83" },
      default_style: :explore,
      bucket: S3_LOGO_BUCKET
    }.merge(CHANNEL_OPTIONS)
end
