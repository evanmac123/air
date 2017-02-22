Searchkick.client_options = {
  retry_on_failure: true
}

case Rails.env
when 'test'
  Searchkick.client_options = {
    http: {
      port: 9250
    }
  }
end
