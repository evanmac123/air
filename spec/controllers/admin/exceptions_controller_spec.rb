require 'spec_helper'
include SteakHelperMethods
describe Admin::ExceptionsController do
  it "Should raise and exception" do
    hot_stuff = FactoryGirl.create(:site_admin)
    sign_in_as(hot_stuff)  # Sign in, otherwise we'll be redirected
    error = false
    begin
      get :show
    rescue
      error = true
    end
    error.should be_true
  end

end
