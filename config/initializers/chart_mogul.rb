unless Rails.env.test?
  ChartMogul.account_token = ENV['CHART_MOGUL_ACCOUNT_TOKEN']
  ChartMogul.secret_key = ENV['CHART_MOGUL_SECRET_KEY']
end

if ENV["RACK_ENV"] == "production"
  ChartMogul::DEFAULT_DATA_SOURCE = 'ds_03de400c-4fb2-11e7-bd51-5feeebb0853a'
elsif ENV["RACK_ENV"] == "staging"
  ChartMogul::DEFAULT_DATA_SOURCE = 'ds_fbbc72cc-4fb1-11e7-af07-7f2f7367daae'
else
  ChartMogul::DEFAULT_DATA_SOURCE = 'ds_c17d9d40-5d2e-11e7-ba44-0fd62ca4b3c3'
end
