require 'spec_helper'

describe Location do
  it { should belong_to :demo }
  it { should validate_presence_of :name }

  describe "on create" do
    it "should set a normalized version of the location's name that we can use for lookups" do
      location = Location.create!(name: "     St.   Very-Bad-Name (in the fields)    ")
      location.reload.normalized_name.should == "st very bad name in the fields"
    end
  end
end
