module Assets
  module Normalizer
    extend ActiveSupport::Concern

    included do
      before_save :normalize_filename
    end

    private

    def normalize_filename
      each_attachment do |name, attachment|
        file_field = name.to_s + "_file_name"
        next unless self.send("#{file_field}_changed?")

        raw_filename = attachment.instance_read(:file_name)
        next unless raw_filename
        
        attachment.instance_write(
          :file_name,
          Assets::Filename.normalize(raw_filename)
        )
      end
    end
  end

end
