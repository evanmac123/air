namespace :airbot do
  namespace :scheduled_task do
    desc "Runs scheduled expense report reminder"
    task :send_expense_reminder => :environment do
      conn = Faraday.new(:url => 'https://slack.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      conn.authorization :Bearer, ENV['SLACK_AUTH_TOKEN']
      
      resp = conn.post do |req|
        req.url '/api/chat.postMessage'
        req.headers['Content-type'] = 'application/json'
        req.body = '{"channel": "C02FKMPBT", "text": "This is an additional test was brought to you by Ryan\'s local dev environment", "as_user": "false"}'
      end
    end
  end
end
