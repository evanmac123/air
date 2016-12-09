class Campaign < ActiveRecord::Base
  belongs_to :demo
  has_attached_file :cover_image,
    {
      styles: { explore: "190x90#" },
      default_style: :explore,
    }

end
