require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalTilesPosted < TotalByEventType 

      def configure opts
        opts.merge!({
          event: "Tile Posted",
          type: "general",
          where:%Q|properties["is_test_user"] == false and (properties["user_type"] == "client admin")|, 
          unit: "week"
        })
      end
    end
  end
end
