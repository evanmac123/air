require 'spec_helper'

describe PagesController do
  it "should not require authentication" do
    get :show, :id => 'invitation'
    response.should_not be_redirect
  end

  it "should not force SSL" do
    $test_force_ssl = true

    request.ssl?.should be_false
    get :show, :id => 'invitation'

    $test_force_ssl = false

    response.should_not be_redirect
  end
end
