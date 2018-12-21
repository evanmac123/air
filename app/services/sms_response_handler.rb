# frozen_string_literal: true

class SmsResponseHandler
  attr_reader :incoming_msg, :from, :response_body

  def self.dispatch(incoming_msg:, from:)
    generator = SmsResponseHandler.new(incoming_msg: incoming_msg, from: from)
    generator.database_action
    generator.dispatch_twilio_response
  end

  def initialize(incoming_msg:, from:)
    @incoming_msg = incoming_msg
    @from = from
    @response_body = ""
  end

  def database_action
    binding.pry
  end

  def dispatch_twilio_response
    twiml = Twilio::TwiML::MessagingResponse.new do |resp|
      resp.message body: response_body
    end

    twiml.to_s
  end
end
