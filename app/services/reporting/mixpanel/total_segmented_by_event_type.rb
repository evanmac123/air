require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalSegmentedByEventType < Report 
      include MixpanelSegmentedResult
      include Segmentation
    end
  end
end
