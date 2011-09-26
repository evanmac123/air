require 'spec_helper'

metal_testing_hack(MichelinRedirectorController)

describe MichelinRedirectorController do
  describe "#show" do
    {"et" => MichelinRedirectorController::MICHELIN_ENROLLMENT_URL,
     "ie"  => MichelinRedirectorController::MICHELIN_INCENTIVE_URL
    }.each do |link_type, expected_url|
      context "when redirecting to #{link_type}" do
        it "should redirect to the proper place with parameters intact" do
          @params = {
            "foo" => "bar",
            "baz" => "quux",
            "link_type" => link_type
          }

          get "show", @params

          response.status.should == 302
          response.headers['Location'].should == "#{expected_url}?baz=quux&foo=bar"
          response.body.should == "Redirecting..."
        end
      end
    end
  end
end
