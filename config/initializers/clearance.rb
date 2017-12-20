Clearance.configure do |config|
  config.mailer_sender = 'Airbo <donotreply@airbo.com>'
  config.password_strategy = Clearance::PasswordStrategies::SHA1
  config.routes = false
  config.allow_sign_up = false

  config.cookie_expiration = lambda do |cookies|
    if cookies[:remember_me]
      10.years.from_now.utc
    else
      20.minutes.from_now.utc
    end
  end
end

module Clearance::Authorization
  def require_login
    unless signed_in?
      deny_access(I18n.t("flashes.failure_when_not_signed_in_html"))
    end
  end
end
