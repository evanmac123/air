require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesCopied < TotalByEventType
      #TODO use default_where_condition
      def configure opts
        opts.merge!({
          event: "Explore page - Interaction",
          type: "general",
          where: where_condition
        })
      end

      def where_condition
        %Q|#{super} and (properties["action"] == "Clicked Copy")|
      end
    end


  end
end
