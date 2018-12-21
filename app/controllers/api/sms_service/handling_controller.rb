# frozen_string_literal: true

class Api::SmsService::HandlingController < Api::ApiController
  skip_before_action :verify_authenticity_token

  def create
    body = params["Body"].downcase
    from = params["From"]
    sid = params["AccountSid"]

    response = SmsResponseHandler.dispatch(incoming_msg: body, from: from, sid: sid)

    render xml: response
  end
end
