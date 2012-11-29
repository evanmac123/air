require 'spec_helper'

describe Tutorial do
  before do
    @james = FactoryGirl.create(:user)
    @demo = @james.demo
    Tutorial.seed_example_user(@demo)
    @kermit = User.where(demo_id: @demo.id, name: Tutorial.example_search_name).first
    @james.befriend(@kermit)
    @kermit.accept_friendship_from(@james)
    @james.relationship_with(@kermit).should == "friends"
  end

  it "should unfriend kermit" do 
    Tutorial.unfriend_kermit_from(@james)
    @james.relationship_with(@kermit).should == "none"
    @kermit.relationship_with(@james).should == "none"
    # try unfriending him again to make sure things don't blow up
    Tutorial.unfriend_kermit_from(@james)
    @james.relationship_with(@kermit).should == "none"
    @kermit.relationship_with(@james).should == "none"
    # call with nil to make sure it doens't blow up
    Tutorial.unfriend_kermit_from(nil)
  end

end
