require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionsByOrganization < Report
      def initialize opts
        super(build(opts))
      end

      def build opts
        opts.merge!({
          event: 'Activity Session - New',
          where:  %Q|(string(properties["organization"])|,
          type: 'unique',
          unit: 'week'
        })

      end

      def endpoint
        @endpoint= "segmentation"
      end

    end
  end
end
