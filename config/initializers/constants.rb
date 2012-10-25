module FailureMessages
  SESSION_EXPIRED = 'Your session has expired. Please log back in to continue.' unless defined?(SESSION_EXPIRED)
end

module SendGrid
  DEV_PASSWORD = "8765432" unless defined?(DEV_PASSWORD)
  DEV_USERNAME = "hengage-devel" unless defined?(DEV_USERNAME)
end
