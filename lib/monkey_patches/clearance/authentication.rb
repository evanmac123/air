module Clearance::Authorization
  def require_login
    unless signed_in?
      deny_access(I18n.t("flashes.failure_when_not_signed_in_html"))
    end
  end
end
