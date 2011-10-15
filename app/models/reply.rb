module Reply
  extend ActiveSupport::Concern

  module InstanceMethods
    def construct_reply(raw_reply)
      self.class.construct_reply(raw_reply)
    end
  end

  module ClassMethods
    def construct_reply(raw_reply)
      result = raw_reply

      # Works like I18n.interpolate, but with interpolation keys set off by
      # @{key} rather than %{key}.

      channel_specific_translations.each do |translation_key, translation_value|
        result.gsub!(/@\{#{translation_key}\}/, translation_value)
      end

      result
    end
  end
end
