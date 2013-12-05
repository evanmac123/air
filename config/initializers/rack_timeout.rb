if Rails.env.test?
  Rack::Timeout.timeout = 86400 # GTFO of my debugging sessions, kthx
else
  Rack::Timeout.timeout = 29
end
