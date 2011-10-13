module Reply
  extend ActiveSupport::Concern

  module InstanceMethods
    def construct_reply(raw_reply)
      self.class.construct_reply(raw_reply)
    end
  end

  module ClassMethods
    def construct_reply(raw_reply)
      I18n.interpolate(raw_reply, channel_specific_translations)
    end
  end
end
