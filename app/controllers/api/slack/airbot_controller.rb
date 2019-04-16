# frozen_string_literal: true

class Api::Slack::AirbotController < Api::ApiController
  include AirbotConcern

  before_action :confirm_token

  def cheer
    result = if params[:text].empty?
      slack_cheer_response(text: Cheer.sample)
    else
      cheer = Cheer.new(body: params[:text])
      cheer.save ? slack_cheer_response(text: cheer.body, title: "#{params[:user_name].upcase} submitted a new cheer!") : slack_cheer_response(error: true)
    end
    render json: result
  end

  private
    def confirm_token
      unless ENV["SLACK_APP_TOKEN"] == params[:token]
        raise ActionController::RoutingError.new("Not Found")
      end
    end
end
