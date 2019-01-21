# frozen_string_literal: true

class SmsResponseHandler
  REMOVED_SUCCESS = "You are unsubscribed from Airbo Alerts. No more messages will be sent. Reply HELP for help."
  UPDATE_FAILURE = "Sorry. Something went wrong with your request. Please contact support@airbo.com."
  ADD_SUCCESS = "You are subscribed to Airbo Alerts. Messages will be sent out whenever there are new tiles on your board. Reply HELP for help."
  HELP_RESPONSE = "Airbo Alerts: Please contact support@airbo.com. Messages are sent out whenever there are new tiles on your board. Text STOP to cancel."
  UNRECOGNIZED_MESSAGE = "Sorry. The message you sent is not recognized by our system. Reply HELP for help."
  attr_reader :incoming_msg, :from, :response_body

  def self.dispatch(incoming_msg:, from:, sid:)
    generator = SmsResponseHandler.new(incoming_msg: incoming_msg, from: from)
    generator.database_action if sid == ENV["TWILIO_ACCOUNT_SID"]
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
                       user && user.update(receives_sms: false) ? REMOVED_SUCCESS : UPDATE_FAILURE
                     when "help", "info"
                       HELP_RESPONSE
                     when "start", "subscribe"
                       user && user.update(receives_sms: true) ? ADD_SUCCESS : UPDATE_FAILURE
                     else
                       UNRECOGNIZED_MESSAGE
    end
  end

  def dispatch_twilio_response
    twiml = Twilio::TwiML::MessagingResponse.new
    twiml.message do |msg|
      msg.body response_body
    end
    twiml
  end
end
