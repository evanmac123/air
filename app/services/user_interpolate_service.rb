class UserInterpolateService
  include Rails.application.routes.url_helpers
  include ClientAdmin::TilesHelper

  attr_accessor :string
  attr_reader :user

  def initialize(string:, user:)
    @string = string
    @user = user
  end

  def interpolate
    interpolate_name
    interpolate_airbo_access_link
    return string
  end

  def interpolate_name
    string.gsub!(/{{name}}/, user.first_name)
  end

  def interpolate_airbo_access_link
    if user.demo
      link = "<a href='#{email_site_link(user, user.demo_id)}'>Airbo</a>"
      string.gsub!(/{{link_to_airbo}}/, link)
    end
  end
end
