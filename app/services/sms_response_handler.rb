# frozen_string_literal: true

class SmsResponseHandler
  REMOVED_SUCCESS = "You are unsubscribed from Airbo Alerts. No more messages will be sent. Reply HELP for help."
  REMOVED_FAILURE = "Sorry. Something went wrong. Please contact support@airbo.com for help unsubscribing."
  HELP_RESPONSE = "Airbo Alerts: Please contact support@airbo.com. Messages are sent out whenever there are new tiles on your board. Text STOP to cancel."
  attr_reader :incoming_msg, :from, :response_body

  def self.dispatch(incoming_msg:, from:, sid:)
    generator = SmsResponseHandler.new(incoming_msg: incoming_msg, from: from)
    generator.database_action if sid == ENV["TWILIO_ACCOUNT_SID"] || true
    generator.dispatch_twilio_response
  end

  def initialize(incoming_msg:, from:)
    @incoming_msg = incoming_msg
    @from = from
    @response_body = ""
  end

  def database_action
    user = User.where(phone_number: from).first
    @response_body = case incoming_msg
                     when "stop", "end", "quit", "cancel", "unsubscribe"
                       user && user.update(receives_sms: false) ? REMOVED_SUCCESS : REMOVED_FAILURE
                     when "help", "info"
                       HELP_RESPONSE
    end
  end

  def dispatch_twilio_response
    twiml = Twilio::TwiML::MessagingResponse.new do |resp|
      resp.message body: response_body
    end
    twiml.to_xml
  end
end
