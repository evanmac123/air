require 'spec_helper'

describe PagesController do
  before(:each) do
    request.host = 'www.test.host'
  end

  it "should not require authentication" do
    get :show, :id => 'marketing'
    response.should_not be_redirect
  end

  it "should not force SSL" do
    begin
      $test_force_ssl = true

      request.ssl?.should be_false
      get :show, :id => 'marketing'

      $test_force_ssl = false

      response.should_not be_redirect
    ensure
      $test_force_ssl = false
    end
  end

  it "should force no SSL on the marketing page" do
    begin
      $test_force_ssl = true
      request.stubs(:ssl?).returns(true)

      get :show, :id => 'marketing'
      response.should be_redirect

    ensure
      $test_force_ssl = false
    end
  end

  it "should force a redirect if no subdomain specified" do
    request.host = 'test.host'
    request.subdomain.should_not be_present

    get :show, :id => 'marketing'

    response.should be_redirect
    response.location.should == "http://www.test.host/"
  end
end
