require 'airbo_mixpanel_client'
require 'reporting/mixpanel'
require 'pry'
module Reporting
  module Mixpanel

    class ActivitySessionByUserTypeAndBoard
      include Mixpanel

      REPORT_COLUMN_HEADERS =["Board", "Client Admin","User","Guest"]
      DATA_SUBKEYS = ["client admin", "ordinary user", "guest"]

      def initialize beg_date=nil, end_date=nil
        @mixpanel = AirboMixpanelClient.new
        @beg_date = beg_date || Date.today.beginning_of_week(:sunday).prev_week(:sunday).at_midnight
        @end_date = end_date || @beg_date.end_of_week(:sunday).end_of_day
      end

      def pull
        result =  @mixpanel.request(endpoint, params)
        raw_data =  extract_report_data(result)
        parse_and_transform raw_data
      end

      private

      def extract_report_data result
        result.fetch("data", {}).fetch("values", [])
      end


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


      def parse_and_transform data_by_board
        data_by_board.each_with_object([REPORT_COLUMN_HEADERS]) do |(board_id, user_activty_in_board), rep_data| 
          rep_data << populate_row_for_board(board_id, user_activty_in_board)
        end
      end

      def populate_row_for_board id, user_activity
        DATA_SUBKEYS.each_with_object([id]) do |subkey, row|
          row << user_activity.fetch(subkey, {}).values.first
        end
      end

      def endpoint
        "segmentation/multiseg"
      end

      def params 
        return {
          event: 'Activity Session - New',
          from_date: date_format(@beg_date), 
          to_date:  date_format(@end_date),
          type: 'unique',
          unit: 'week',
          inner: 'properties["user_type"]',
          outer: 'properties["game"]'
        }
      end

    end

  end
end
