class Mail::Message
  def deliver_with_outgoing_email_logging
    deliver_without_outgoing_email_logging

    OutgoingEmail.create(subject: self.subject,
                         from:    self.from.join(","),
                         to:      self.to.join(","),
                         raw:     self.to_s
                        )
  end

  alias_method_chain :deliver, :outgoing_email_logging
end
