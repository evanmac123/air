require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueActivitySessionsByOrganization < Report

      def initialize opts #{from_date: ?, to_date: ?}
        super(configure(opts))
        @summary = {} 
        @endpoint= "segmentation"
      end

      def configure opts
        opts.merge!({
          event: "Activity Session - New",
          on: %Q|string(properties["organization"])|,
          unit: 'week',
          type: 'unique',
        })

      end

      def count_orgs_with_uniq_sessions_gt_zero
        summarize_data
        summary.select{|k, v| v>0 && k!="undefined"}.count
      end

      def summarize_data
        values.each do |org_id, series_data|
          tot_uniq_sessions = series_data.values.sum
          @summary[org_id]=tot_uniq_sessions
        end
      end

      def endpoint
        @endpoint
      end

      def summary
        @summary
      end

      def values 
        @values ||= raw_data.fetch("data",{}).fetch("values", {})
      end

      def series
        @series ||= raw_data.fetch("data",{}).fetch("series", [])
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
