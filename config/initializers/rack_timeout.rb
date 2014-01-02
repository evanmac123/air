if Rails.env.production?
  Rack::Timeout.timeout = 29
else
  Rack::Timeout.timeout = 86400 # GTFO of my debugging sessions, kthx
end
