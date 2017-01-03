require 'spec_helper'

describe Location do
  it { is_expected.to belong_to :demo }
  it { is_expected.to validate_presence_of :name }

  describe "on create" do
    it "should set a normalized version of the location's name that we can use for lookups" do
      location = Location.create!(name: "     St.   Very-Bad-Name (in the fields)    ")
      expect(location.reload.normalized_name).to eq("st very bad name in the fields")
    end
  end
end
