require 'spec_helper'

describe PagesController do
  it "should not require authentication" do
    get :show, :id => 'new_marketing'
    response.should_not be_redirect
  end

  it "should not force SSL" do
    begin
      $test_force_ssl = true

      request.ssl?.should be_false
      get :show, :id => 'new_marketing'

      $test_force_ssl = false

      response.should_not be_redirect
    ensure
      $test_force_ssl = false
    end
  end
end
