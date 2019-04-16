# frozen_string_literal: true

class Airbot
  SLASH_COMMAND_RESPONSE_TYPES = {
    error: {
      response_type: "ephemeral",
      title: "An error occurred",
      text: "You're cheer did not save. Please try again later.",
      color: "#C90404",
      giphy_type: "fail"
    },
    cheer: {
      response_type: "in_channel",
      title: "A new cheer has been submitted!",
      text: "Airbo on three... 1, 2, 3, AIRBO!",
      color: "#48BFFF",
      giphy_type: "cheer"
    }
  }.freeze

  attr_reader :conn

  def initialize
    @conn = Faraday.new(url: "https://slack.com") do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end
    @conn.authorization :Bearer, ENV["SLACK_AUTH_TOKEN"]
  end

  def slack_method(method, body)
    conn.post do |req|
      req.url "/api/#{method}"
      req.headers["Content-type"] = "application/json"
      req.body = body.to_json
    end
  end

  def self.slash_command_response(type, opts = {})
    response_commands = SLASH_COMMAND_RESPONSE_TYPES[type]
    {
      response_type: response_commands[:response_type],
      attachments: [
        msg_attachment(
          title: opts[:title] || response_commands[:title],
          text: opts[:text] || response_commands[:text],
          fallback: opts[:text] || response_commands[:text],
          color: opts[:color] || response_commands[:color],
          random_giphy: opts[:giphy_type] || response_commands[:giphy_type]
        )
      ]
    }
  end

  def self.msg_attachment(opts)
    {
      fallback: opts[:fallback] || opts[:text],
      color: opts[:color],
      pretext: opts[:pretext],
      author_name: opts[:author_name],
      author_link: opts[:author_link],
      author_icon: opts[:author_icon],
      title: opts[:title],
      title_link: opts[:title_link],
      text: opts[:text],
      image_url: opts[:random_giphy] ? random_giphy(opts[:random_giphy]) : opts[:image_url],
      thumb_url: opts[:thumb_url],
      footer: opts[:footer],
      footer_icon: opts[:footer_icon],
      ts: opts[:ts],
    }
  end

  private
    def self.giphy_api_endpoint(type)
      "https://api.giphy.com/v1/gifs/random?api_key=#{ENV['GIPHY_API_KEY']}&tag=#{type}&rating=G"
    end

    def self.random_giphy(type)
      begin
        uri  = URI(giphy_api_endpoint(type))
        resp = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)
        resp[:data][:images][:fixed_width][:url]
      rescue
        "https://media0.giphy.com/media/l41lNeVPFM7LH9X7q/200w.gif"
      end
    end
end
