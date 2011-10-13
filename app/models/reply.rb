module Reply
  extend ActiveSupport::Concern

  module InstanceMethods
    def construct_reply(raw_reply)
      self.class.construct_reply(raw_reply)
    end
  end

  module ClassMethods
    def construct_reply(raw_reply)
      I18n.t(
        :generic_reply, # this is a hack
        {:default => raw_reply}.merge(channel_specific_translations)
      )
    end
  end
end
