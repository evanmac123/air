# frozen_string_literal: true

class Api::Slack::AirbotController < Api::ApiController
  before_action :confirm_token

  def cheer
    cheer = Cheer.new(body: params[:text])
    response = if cheer.save
      {
        response_type: "in_channel",
        attachments: [
          {
            title: "#{params[:user_name].upcase} submitted a new cheer!",
            text: "\"#{params[:text]}\"",
            fallback: params[:text],
            color: "#48BFFF",
            image_url: random_giphy("cheer")
          }
        ]
      }
    else
      {
        response_type: "ephemeral",
        attachments: [
          {
            title: "An error occurred",
            text: "You're cheer did not save. Please try again later.",
            fallback: "You're cheer did not save. Please try again later.",
            color: "#C90404",
            image_url: random_giphy("error")
          }
        ]
      }
    end

    render json: response
  end

  private
    def confirm_token
      unless ENV["SLACK_APP_TOKEN"] == params[:token]
        raise ActionController::RoutingError.new("Not Found")
      end
    end

    def giphy_api_endpoint(type)
      "https://api.giphy.com/v1/gifs/random?api_key=#{ENV['GIPHY_API_KEY']}&tag=#{type}&rating=G"
    end

    def random_giphy(type)
      begin
        uri  = URI(giphy_api_endpoint(type))
        resp = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
        resp[:data][:images][:fixed_width][:url]
      rescue
        "https://media0.giphy.com/media/l41lNeVPFM7LH9X7q/200w.gif"
      end
    end
end
