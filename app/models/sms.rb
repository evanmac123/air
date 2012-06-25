require 'delayed/syck_ext' # to fix retarded YAML serialization of SMS module

module SMS
  extend Reply

  def self.send_message(to, body, send_at = nil, options={})
    return unless to.present? # no sending to blank numbers
    return if muted_user?(to)

    delay_params = send_at ? {:run_at => send_at} : {}
    from_number = if options[:from_demo]
                    options[:from_demo].phone_number || TWILIO_PHONE_NUMBER
                  else
                    case to
                      when String
                        TWILIO_PHONE_NUMBER
                      when User
                        (to.demo.phone_number || TWILIO_PHONE_NUMBER)
                    end
                  end

    to_number = case to
                  when String
                    to
                  when User
                    to.phone_number
                end

    return if to_number.blank?

    if to.kind_of?(User)
      @to_user = to
      to.bump_mt_texts_sent_today
    end

    interpolated_body = construct_reply(body.dup)

    Delayed::Job.enqueue(OutgoingMessageJob.new(from_number, to_number, interpolated_body), delay_params)
  end

  def self.bulk_send_messages(user_ids, body)
    users = User.where(:id => user_ids)
    users.each {|user| self.send_message(user, body)}
  end

  def self.channel_specific_translations
    {
      "reply here" => (@to_user ? "Your username is #{ @to_user.sms_slug } (text MYID if you forget). To play, text to this #." : "To play, text to this #." )    
    }
  end

  protected

  def self.muted_user?(to)
    to.kind_of?(User) && to.last_muted_at.present? && to.last_muted_at > 24.hours.ago
  end
end
