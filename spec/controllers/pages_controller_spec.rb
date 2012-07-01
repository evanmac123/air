require 'spec_helper'

describe PagesController do
  before(:each) do
    request.host = 'www.test.host'
    $test_force_ssl = true
  end

  it "should force a redirect if no subdomain specified" do
    request.host = 'test.host'
    request.subdomain.should_not be_present

    get :show, :id => 'marketing'

    response.should be_redirect
    response.location.should == "https://www.test.host/"
  end
end
