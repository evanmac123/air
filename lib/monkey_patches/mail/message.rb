class Mail::Message
  def deliver_with_outgoing_email_logging
    deliver_without_outgoing_email_logging

    begin
      OutgoingEmail.create(subject: self.subject,
                           from:    self.from.join(","),
                           to:      self.to.join(","),
                           raw:     self.to_s
                          )
    rescue StandardError => e
      Airbrake.notify(e)
    end
  end

  alias_method_chain :deliver, :outgoing_email_logging
end
