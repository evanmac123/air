class Charts::BoardUniqueLoginActivityDigestsChart < Charts::ChartBase
  def get_requested_series(list_of_series)
    list_of_series.map { |s|
      {
        data: self.send(s)
      }
    }
  end

  def unique_login_activity
    Charts::Queries::BoardUniqueLoginActivity.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def cumulative_login_activity
    cumulative_data(unique_login_activity)
  end

  def digests_sent
    Charts::Queries::BoardDigestsSent.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def cumulative_digests_sent
    cumulative_data(digests_sent)
  end

  def follow_up_digests_sent
    Charts::Queries::BoardFollowUpDigestsSent.new(board_from_params, time_unit).analysis_from_cached_query(start_date, end_date).to_a
  end

  def cumulative_follow_up_digests_sent
    cumulative_data(follow_up_digests_sent)
  end
end
