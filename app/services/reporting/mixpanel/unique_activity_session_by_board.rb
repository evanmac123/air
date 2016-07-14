require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel

    class UniqueActivitySessionByBoard < Report

      protected

      def endpoint
        @endpoint= "segmentation"
      end

      def params
        return {
          event: 'Activity Session - New',
          type:  'unique',
          limit: 150,
          on:    'string(properties["game"])',
          unit: 'day'
        }
      end

    end
  end
end
