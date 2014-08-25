module Assets
  module Normalizer
    def self.included(base)
      base.send :before_save, :normalize_filename
    end

    private

    def normalize_filename
      each_attachment do |name, attachment|
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
