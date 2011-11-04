module SMS
  class OutgoingMessageJob
    def initialize(from, to, body)
      @from = from
      @to = to
      @body = body
    end

    def perform
      return if @from.dummy_phone_number?

      begin
        Twilio::SMS.create(:from => @from,
                            :to   => @to,
                            :body => @body)
      rescue StandardError => e
        Airbrake.notify(
          :error_class   => e.class,
          :error_message => e.message,
          :parameters    => {
            :from => @from,
            :to   => @to,
            :body => @body
          }
        )
      end
    end
  end
end
