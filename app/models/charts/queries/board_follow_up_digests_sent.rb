class Charts::Queries::BoardFollowUpDigestsSent < Charts::Queries::BoardQuery
  def query
    board.tiles_digests.where(followup_delivered: true).joins(:follow_up_digest_email).group_by_period(time_unit, "follow_up_digest_emails.send_on").count
  end

  def cache_key
    "#{board.id}:follow_up_digests_sent:#{time_unit}"
  end
end
