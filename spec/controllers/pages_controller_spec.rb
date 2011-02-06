require 'spec_helper'

describe PagesController do
  it "should not require authentication" do
    get :show, :id => 'invitation'
    response.should_not be_redirect
  end
end
