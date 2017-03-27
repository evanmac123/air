class Charts::BoardUniqueLoginActivityDigestsChart < ChartBase
  def get_requested_series(list_of_series)
    list_of_series.map { |s|
      {
        data: self.send(s)
      }
    }
  end

  def unique_login_activity
    Query::BoardUniqueLoginActivity.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def cumulative_login_activity
    cumulative_data(unique_login_activity)
  end

  def digests_sent
    Query::BoardDigestsSent.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def cumulative_digests_sent
    cumulative_data(digests_sent)
  end
end
