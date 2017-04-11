class Charts::Queries::BoardUniqueLoginActivity < Charts::Queries::BoardQuery
  MIXPANEL_TIME_LIMIT = 1824.days.ago

  def query
    raw_data = $mixpanel_client.request("jql", { script: jql_script })
    raw_data.map { |hsh| arr = hsh.values.flatten; [Time.at(arr[0] / 1000.0), arr[1]] }
  end

  def cache_key
    "#{board.id}:unique_activity_sessions:#{time_unit}"
  end

  def start_date
    MIXPANEL_TIME_LIMIT.strftime("%Y-%m-%d")
  end

  def end_date
    Date.today.strftime("%Y-%m-%d")
  end

  def jql_script
    %Q|
    function timeBucket() {
      if ("#{time_unit}" == "quarter") {
        return mixpanel.quarterly_time_buckets;
      } else if ("#{time_unit}" == "month") {
        return mixpanel.monthly_time_buckets;
      } else if ("#{time_unit}" == "week") {
        return mixpanel.weekly_time_buckets;
        }
      }

      function main() {
        return Events({
          from_date: "#{start_date}",
          to_date: "#{end_date}",
          event_selectors: [
            {
              event: "Activity Session - New",
              selector: 'properties["game"] == #{board.id} and properties["user_type"] != "site admin" and properties["user_type"] != "guest"'
            }
          ]
        })
        .groupByUser([
          mixpanel.numeric_bucket('time', timeBucket())],
          function() {
            return 1;
          })
        .groupBy([
          function(row) { return row.key.slice(1) }],
          mixpanel.reducer.count());
        }|
  end
end
