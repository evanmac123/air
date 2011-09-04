require 'spec_helper'

metal_testing_hack(MichelinRedirectorController)

describe MichelinRedirectorController do
  describe "#show" do
    it "should redirect to the proper place with parameters intact" do
      @params = {
        "foo" => "bar",
        "baz" => "quux"
      }

      get "show", @params

      response.status.should == 302
      response.headers['Location'].should == "#{MichelinRedirectorController::MICHELIN_URL}?baz=quux&foo=bar"
    end
  end
end
