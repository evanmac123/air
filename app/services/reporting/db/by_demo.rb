include "reporint/db" 
module Reporting
  module Db
    class ByBoard < Base

      def initialize demo_id, beg_date, end_date, interval
        super
        @demo_id  = demo_id
        @demo  = Demo.find(@demo_id)
      end
    end
  end
end
