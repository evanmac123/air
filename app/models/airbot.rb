# frozen_string_literal: true

class Airbot
  ROBOT_JOKES = [
    "Why was the android itchy?...\nRoboticks.\n",
    "What did the robot call it’s creator?...\nDa-ta\n",
    "What kind or androids do you find in the arctic?...\nSnobots.\n",
    "What do you call an android crew team?...\nRowbots.\n",
    "Why did the robot run away?...\nIt heard an electric can opener.\n",
    "What kind of salad do androids like?...\nOnes made with ice-borg lettuce.\n",
    "Why did the robot cross the road?...\nBecause he wasn’t chicken (robots have no emotions!)\n",
    "What did the droid do at lunch time?...\nHad a byte…\n",
    "What musical instrument do some robots play?...\nCyborgans.\n",
    "What do they do every summer in robot neighborhoods?...\nHave a ro-block party.\n",
    "Why did the robot get angry so often?...\nPeople kept pushing it’s buttons.\n",
    "Why shouldn’t R2D2 be allowed in movies?...\nHe says so many foul words they have to bleep everything he says!\n",
    "What was the robot’s favorite style of music?...\nHeavy Metal.\n",
    "Why is a droid mechanic never lonely?...\nBecause he’s always making new friends.\n",
    "Why wasn’t there an oil can in the x-wing fighter garage?...\nBB8 it.\n",
    "What did the robot say when he was asked to shut down?...\nRo-NOT!\n",
    "How does C3PO communicate when he’s on the moon of Endor?...\nEwok-ie talkie.\n",
    "What do you get when you cross a robot with a tractor?...\nA transfarmer.\n",
    "What do you call a pirate droid?...\nArrrrgh-2-D2\n",
    "Why was the robot feeling bad?...\nIt had a virus.\n",
    "What is R2D2 short for?...\nBecause he has small legs.\n",
    "Does C3PO have any siblings?...\nYes, he has two transisters.\n",
    "How do you get down from a bantha?...\nYou don’t. You get down from a goose.\n",
    "Why did the robot go to the shopping mall?...\nIt had hardware and software – but it needed underware.\n",
    "Who was the robot’s favorite author?...\nAnne Droid.\n",
    "What happens when a robot falls in muddy water?...\nIt gets wet and muddy.\n",
    "Why did the robot fall off his bike?...\nHe hadn’t ridden in a long time and was a little rusty.\n",
    "Why was the robot so tired when it finally got home?...\nIt had a hard drive.\n",
    "Who wrote the book titled: “My Life as a Robot?”...\nCy Borg.\n",
    "Where do robots sit?...\nOn their robottoms.\n",
    "What do you call a pirate robot?...\nArrrrr-2-D2\n",
    "Why is a robot builder never lonely?...\nHe’s always making new friends.\n",
    "How do baby robots drink milk?...\nFrom a robottle.\n",
    "Why did the robot cross the road?...\nIt was programmed to be a chicken.\n",
    "What do robots wear during the winter?...\nRoboots.\n",
    "What excuse did Ray give for not having her homework?...\nBB-8 it.\n"
  ]

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

  def self.random_joke(user = "Airboer")
    joke_response = [
      "Hahahaha. 😅 I'm just too much sometimes. This has been fun, #{user}.",
      "Hahaha... That was TOO funny!",
      "🤭 Jk jk jk. LOL. I hope you enjoyed this joke, #{user}!",
      "Who said robots can't be funny, #{user}? 🤖",
      "LMFAO! Thanks for the fun distraction, #{user}.",
      "Get it, #{user}?! Hahaha 😂",
      "#{user}! 🤭😂😅"
    ]
    ROBOT_JOKES[rand(ROBOT_JOKES.length)] + joke_response[rand(joke_response.length)]
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
