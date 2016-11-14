require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionsByOrganization < Report
      def initialize opts #{from_date: ?, to_date: ?}
        super(build(opts))
      end

      def build opts
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
            "series"=> [
              "2016-09-05",
              "2016-09-12",
              "2016-09-19",
              "2016-09-26",
              "2016-10-03",
              "2016-10-10",
              "2016-10-17",
              "2016-10-24",
              "2016-10-31",
              "2016-11-07"
            ],
            "values"=> {
              "272"=> {
                "2016-09-05"=>0,
                "2016-08-08"=>0,
                "2016-09-26"=>0,
                "2016-04-11"=>0,
                "2016-06-20"=>0,
                "2016-10-24"=>0,
                "2016-10-03"=>0
              },
              "undefined"=> {
                "2016-05-23"=>17,
                "2016-09-05"=>2,
                "2016-08-08"=>2,
                "2016-09-26"=>3,
                "2016-04-11"=>3,
                "2016-06-20"=>3,
                "2016-10-24"=>1,
                "2016-10-03"=>1}
            }
          }
        }
      end
    end
  end
end
