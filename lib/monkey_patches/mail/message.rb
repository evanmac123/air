class Mail::Message
  def deliver_with_outgoing_email_logging
    deliver_without_outgoing_email_logging

    begin
      OutgoingEmail.create(subject: self.subject,
                           from:    join_if_joinable(self.from),
                           to:      join_if_joinable(self.to),
                           raw:     self.to_s
                          )
    rescue StandardError => e
      Airbrake.notify(e)
    end
  end

  def join_if_joinable(values_to_join)
    return values_to_join unless values_to_join.respond_to?(:join)
    values_to_join.join(",")
  end

  alias_method_chain :deliver, :outgoing_email_logging
end
