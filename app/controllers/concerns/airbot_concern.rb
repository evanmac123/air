# frozen_string_literal: true

module AirbotConcern
  def slack_cheer_response(error: false, text: "", title: "Random Cheer from the Airbo Archives")
    {
      response_type: error ? "ephemeral" : "in_channel",
      attachments: [
        {
          title: error ? "An error occurred" : title,
          text: error ? "You're cheer did not save. Please try again later." : "\"#{text}\"",
          fallback: error ? "You're cheer did not save. Please try again later." : "\"#{text}\"",
          color: error ? "#C90404" : "#48BFFF",
          image_url: random_giphy(error ? "fail" : "cheer")
        }
      ]
    }
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
