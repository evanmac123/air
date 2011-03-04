class ConferenceFeedsController < ApplicationController
  before_filter :authenticate
  before_filter :set_conference_feed_page

  def show
    @demo  = Demo.includes(:users, :acts).where(:company_name => 'Employee Health Care Conference').first
    @users = @demo.users.ranked.order('ranking ASC')
    @acts  = @demo.acts.order('created_at DESC').limit(20).includes(:user, {:rule => :key})
  end

  protected

  def authenticate
    return true if Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == "ehcc" && password == "salud"
    end
  end

  def set_conference_feed_page
    @conference_feed_page = true
  end
end
