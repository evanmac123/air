# frozen_string_literal: true

class Api::Slack::AirbotController < Api::ApiController
  before_action :confirm_token

  def cheer
    result = if params[:text].empty?
      Airbot.slash_command_response(
        :cheer,
        title: "Random Cheer from the Airbo Archives",
        text: Cheer.sample
      )
    else
      submit_cheer
    end
    render json: result
  end

  def event_subscription
    event = params[:event]
    response = if event[:text].include?("joke")
      {
        text: Airbot.random_joke("<@#{event[:user]}>"),
        random_giphy: "laughing"
      }
    else
      {
        text: "Beep boop. Hi <@#{event[:user]}>! Nice to meet you. I'm AirBot and here to help!",
        random_giphy: "hello"
      }
    end
    Airbot.new.slack_method("chat.postMessage",
      channel: event[:channel],
      as_user: "false",
      text: response[:text],
      attachments: [
        Airbot.msg_attachment(
          color: "#48BFFF",
          random_giphy: response[:random_giphy]
        )
      ]
    )
    render json: { ok: true, challenge: params[:challenge] }
  end

  private

    def submit_cheer
      cheer = Cheer.new(body: params[:text])
      if cheer.save
        Airbot.slash_command_response(
          :cheer,
          text: cheer.body,
          title: "#{params[:user_name].upcase} submitted a new cheer!"
        )
      else
        Airbot.slash_command_response(:error)
      end
    end

    def confirm_token
      unless ENV["SLACK_APP_TOKEN"] == params[:token] || params[:challenge]
        raise ActionController::RoutingError.new("Not Found")
      end
    end
end

# {
#   "team_id"=>"T02FKMPAZ",
#   "api_app_id"=>"AHA1KQ28K",
#   "event"=>{
#     "client_msg_id"=>"ba655dff-e417-4900-b308-8307a1a40dd0",
#     "type"=>"app_mention",
#     "text"=>"Hello <@UHYNM254L>",
#     "user"=>"UAHC3R48Y",
#     "ts"=>"1555521394.002600",
#     "channel"=>"G5A74FQ4W",
#     "event_ts"=>"1555521394.002600"
#   },
