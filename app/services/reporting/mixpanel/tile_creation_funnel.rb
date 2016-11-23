require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TileCreationFunnel < Report

      #def initialize opts
        #super(configure(opts))
      #end

      def configure opts
        opts.merge!({
          funnel_id: 2080300,
          interval: 30,
        })
      end

      def endpoint
        "funnels"
      end


    end



  end
end
