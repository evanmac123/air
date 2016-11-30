require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class TotalByEventType < Report 
      include MixpanelUnsegmentedResult
      include Segmentation
    end
  end
end
