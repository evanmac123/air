class SessionsController < Clearance::SessionsController
  def url_after_create
    activity_path
  end
end
