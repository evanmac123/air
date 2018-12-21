# frozen_string_literal: true

class Api::SmsService::HandlingController < Api::ApiController
  def create
    head :ok, content_type: "text/html"
    body = params["Body"].downcase
    from = params["From"]
    sid = params["MessagingServiceSid"]

    SmsResponseHandler.dispatch(incoming_msg: body, from: from) if sid == ENV["TWILIO_ACCOUNT_SID"]
  end
end
