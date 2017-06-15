unless Rails.env.test?
  ChartMogul.account_token = ENV['CHART_MOGUL_ACCOUNT_TOKEN']
  ChartMogul.secret_key = ENV['CHART_MOGUL_SECRET_KEY']
end

if Rails.env.production?
  ChartMogul::DEFAULT_DATA_SOURCE = 'ds_03de400c-4fb2-11e7-bd51-5feeebb0853a'
else
  ChartMogul::DEFAULT_DATA_SOURCE = 'ds_fbbc72cc-4fb1-11e7-af07-7f2f7367daae'
end
