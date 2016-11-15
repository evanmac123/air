require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionsByOrganization < Report
      def initialize opts #{from_date: ?, to_date: ?}
        super(configure(opts))
      end

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["organization"])|,
          unit: 'week',
          type: 'unique',
        })

      end

      def endpoint
        @endpoint= "segmentation"
      end

      private
      def sample_data
        {
          "legend_size"=>2,
          "data"=> {
            "series"=>["2016-11-07"], 
            "values"=>{
              "272"=>{"2016-10-31"=>0, "2016-11-07"=>2},
              "123"=>{"2016-10-31"=>0, "2016-11-07"=>2},
              "undefined"=>{"2016-10-31"=>1, "2016-11-07"=>4}
            }
          }
        }
      end
    end
  end
end
