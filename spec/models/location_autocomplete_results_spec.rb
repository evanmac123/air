require "spec_helper"

describe LocationsController::LocationAutocompleteResults do
  describe "#to_json" do
    it "should not HTML-escape search results" do
      location_name = "O'Malley's Alley"
      results = LocationsController::LocationAutocompleteResults.new([location_name])
      returned_name = JSON.parse(results.to_json).first['label']
      returned_name.should == location_name
    end
  end
end
