module Tile::TileImageProcessing
  extend ActiveSupport::Concern

  MAX_REMOTE_MEDIA_URL_LENGTH = 2000

  included do
    before_save :prep_image_processing, if: :image_changed?
    after_save :process_image, if: :image_changed?
  end

  def prep_image_processing
    validate_remote_media_url

    if remote_media_url.present?
      self.thumbnail_processing = true
      self.image_processing = true
    end
  end

  def validate_remote_media_url
    # Prevent remote_media_urls that are too long without preventing the entire tile from saving.
    if remote_media_url.to_s.length > MAX_REMOTE_MEDIA_URL_LENGTH
      self.remote_media_url = nil
    end
  end

  def process_image
    TileImageProcessJob.perform_later(id: self.id)
  end

  def image_changed?
    changes.keys.include?("remote_media_url")
  end
end
