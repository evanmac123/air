require 'spec_helper'

describe VerificationsController do
  it "should redirect if not signed in" do
    get :show
    response.should be_redirect
  end
    

end
