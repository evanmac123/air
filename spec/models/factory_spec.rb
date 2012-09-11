require 'spec_helper'

describe "Make sure our rspec factories are set up properly" do 
  before(:each) do
    # Make sure there are no demos or users
    Demo.find_each {|f| f.destroy}
    Demo.count.should == 0
    User.count.should == 0
    Rule.count.should == 0
  end

  it "should associate a user to a demo without creating duplicates" do
    @first_demo = FactoryGirl.create(:demo)
    Demo.count.should == 1
    User.count.should == 0

    @first_user_in_demo = FactoryGirl.create(:user, demo: @first_demo)
    Demo.count.should == 1
    User.count.should == 1
    Demo.all.should == [@first_demo]
  end

end
