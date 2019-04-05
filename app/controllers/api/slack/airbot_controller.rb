# frozen_string_literal: true

class Api::Slack::AirbotController < Api::ApiController
  before_action :confirm_token

  def cheer
    render json: {
    attachments: [
      {
        title: "*#{params[:user_name]}* submitted a new cheer!",
        text: "\"#{params[:text]}\"",
        fallback: params[:text],
        color: "#48BFFF"
      }
    ]
  }
    # {"token"=>"3e2RasO41aeO9cIpvgDW4LM3",
    #  "team_id"=>"T02FKMPAZ",
    #  "team_domain"=>"airbo",
    #  "channel_id"=>"DAHC3RACQ",
    #  "channel_name"=>"directmessage",
    #  "user_id"=>"UAHC3R48Y",
    #  "user_name"=>"ryan",
    #  "command"=>"/cheer",
    #  "text"=>"Hello world",
    #  "response_url"=>"https://hooks.slack.com/commands/T02FKMPAZ/602050783620/wduFvZ9gTlbA3uo9xieQdVz3",
    #  "trigger_id"=>"603522059398.2529737373.dc40dbdef877c3071e5a4f093fcd0d82",
    #  "format"=>:json,
    #  "controller"=>"api/slack/airbot",
    #  "action"=>"cheer"}
  end

  private
    def confirm_token
      unless ENV["SLACK_APP_TOKEN"] == params[:token]
        raise ActionController::RoutingError.new("Not Found")
      end
    end
end
