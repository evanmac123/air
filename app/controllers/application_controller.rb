class ApplicationController < ActionController::Base
  # In here temporarily until we have enough for people to look at. 
  before_filter :authenticate

  include Clearance::Authentication
  protect_from_forgery
end
