require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel
    class UniqueSegmentedEventsBase < UniqueEventsBase
      include MixpanelSegmentedResult
    end
  end
end
