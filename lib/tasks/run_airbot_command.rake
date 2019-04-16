namespace :airbot do
  namespace :scheduled_task do
    desc "Runs scheduled expense report reminder"
    task :send_expense_reminder => :environment do
      return unless (1..5).to_a.include?(Date.today.wday)

      conn = Faraday.new(:url => 'https://slack.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn.authorization :Bearer, ENV['SLACK_AUTH_TOKEN']

      uri  = URI("https://api.giphy.com/v1/gifs/random?api_key=#{ENV['GIPHY_API_KEY']}&tag=money&rating=G")
      money_gif = JSON.parse(Net::HTTP.get(uri), symbolize_names: true)[:data][:images][:fixed_width][:url]

      body = {
        channel: 'DAHC3RACQ',
        as_user: 'false',
        attachments: [
          {
            title: 'Reminder to Submit Expenses',
            text: "There are just x more days until payday processing",
            fallback: "There are just x more days until payday processing",
            color: "#26d100",
            image_url: money_gif
          }
        ]
      }.to_json

      resp = conn.post do |req|
        req.url '/api/chat.postMessage'
        req.headers['Content-type'] = 'application/json'
        req.body = body
      end
    end
  end
end
