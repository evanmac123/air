#______________________________________________________________________
#  SAMPLE DATA RETURNED
#______________________________________________________________________
#
# @data_by_board is a hash that looks like this 
#  where the top level key is the board id and the subkeys are the the
#  breakdown by user type
#  
#  {"1052"=>
#   {"client admin"=>{"2016-06-06"=>1, "2016-06-13"=>0},
#    "ordinary user"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "site admin"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "guest"=>{"2016-06-06"=>0, "2016-06-13"=>0}},
#   "560"=>
#   {"client admin"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "ordinary user"=>{"2016-06-06"=>1, "2016-06-13"=>0},
#    "site admin"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "guest"=>{"2016-06-06"=>0, "2016-06-13"=>0}},
#   "665"=>
#   {"client admin"=>{"2016-06-06"=>1, "2016-06-13"=>0},
#    "ordinary user"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "site admin"=>{"2016-06-06"=>0, "2016-06-13"=>0},
#    "guest"=>{"2016-06-06"=>0, "2016-06-13"=>0}},
#  }
#




require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
module Reporting
  module Mixpanel

    class ActivitySessionByUserTypeAndBoard < Report 

      protected

      def endpoint
        @endpoint= "segmentation/multiseg"
      end

      def parse_and_transform data
        data.each_with_object([report_column_headers]) do |(key, data_values), rep_data| 
          rep_data << populate_row_for_board(key, data_values)
        end
      end

      def params 
        {
          event: 'Activity Session - New',
          type: 'unique',
          unit: 'week',
          inner: 'properties["user_type"]',
          outer: 'properties["game"]'
        }
      end

      private

      def report_column_headers 
        ["Board", "Client Admin","User","Guest"]
      end 

      def data_subkeys 
        ["client admin", "ordinary user", "guest"]
      end

      def populate_row_for_board id, data
        data_subkeys.each_with_object([id]) do |subkey, row|
          row << data.fetch(subkey, {}).values.first
        end
      end

    end

  end
end
