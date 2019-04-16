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
      # unless ENV["SLACK_APP_TOKEN"] == params[:token]
      #   raise ActionController::RoutingError.new("Not Found")
      # end
    end
end
