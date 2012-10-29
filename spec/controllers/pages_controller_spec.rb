require 'spec_helper'

describe PagesController do
  before(:each) do
    request.host = 'www.test.host'
    $test_force_ssl = true
  end

  it "should force a redirect if a subdomain is specified" do
    request.host = 'sub.test.host'
    request.subdomain.should be_present

    get :show, :id => 'marketing'

    response.should be_redirect
    response.location.should == "https://test.host/"
  end
end
