module Reporting
  module Db
    class Base
      attr_reader :beg_date, :end_date

      def initialize  beg_date, end_date, interval
        @beg_date = beg_date.send("beginning_of_#{interval}")
        @end_date = end_date.end_of_day
        @interval = interval
        @series_interval=(interval == "quarter") ? "3 months" : "1 #{interval}"
      end



      protected

      def query_builder relation, interval_field, key_field, condition

        relation
          .select(count_by_interval(interval_field, key_field))
          .where(condition)
          .to_sql
      end

      def count_by_interval interval_field, key_field
        "DATE_TRUNC('#{@interval}', #{interval_field}::Timestamp AT TIME ZONE  '-4:00' ) AS interval, COUNT(#{key_field}) AS interval_count"
      end


      def wrapper_sql select_for_primary_data
        b = beg_date
        e = end_date
        <<-SQL
                 SELECT
                 interval
                 , interval_count
                 , SUM(interval_count ) OVER (ORDER BY interval) AS cumulative_count

                 FROM
                 (

                 SELECT interval ,MAX(interval_count) AS interval_count FROM
                 (
                   SELECT GENERATE_SERIES (
                           DATE_TRUNC('#{@interval}', TIMESTAMP '#{b}'),
                           DATE_TRUNC('#{@interval}', TIMESTAMP '#{e}'), INTERVAL '#{@series_interval}'
                   ) AS interval,
                   0 AS interval_count

                  UNION

        #{select_for_primary_data}

                  GROUP BY 1 ORDER BY 1
                 ) sub1
                 GROUP BY interval
                 ) grouped_data
        SQL
      end

    end
  end
end
