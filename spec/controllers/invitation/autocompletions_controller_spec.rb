require 'spec_helper'
describe Invitation::AutocompletionsController do
  
  before do
    User.delete_all
    Demo.delete_all
    
    @demo1 = FactoryGirl.create(:demo, :name => "Bratwurst")
    @demo2 = FactoryGirl.create(:demo, :name => "Gleason")

    @user0 = FactoryGirl.create(:claimed_user, :name => "Joining Now 1", :demo => @demo1, :email => "angel@hopper.com", :slug => "angelfire", :sms_slug => "angelfire")
    @user1 = FactoryGirl.create(:claimed_user, :name => "mad house", :demo => @demo1, :email => "manly@hopper.com", :slug => "beau", :sms_slug => "beau")
    @user2 = FactoryGirl.create(:claimed_user, :name => "Lucy", :demo => @demo1, :email => "boob@hopper.com", :slug => "lou", :sms_slug => "lou")
    @user3 = FactoryGirl.create(:claimed_user, :name => "Strange", :demo => @demo1, :email => "surround@hopper.com", :slug => "think", :sms_slug => "think")
    @user4 = FactoryGirl.create(:claimed_user, :name => "Parking Lot", :demo => @demo1, :email => "chevo@hopper.com", :slug => "master", :sms_slug => "master")
    @user5 = FactoryGirl.create(:claimed_user, :name => "Lucy", :demo => @demo2, :email => "boob@biker.com", :slug => "sterling", :sms_slug => "sterling")
    @user6 = FactoryGirl.create(:claimed_user, :name => "Brewski", :demo => @demo2, :email => "three@biker.com", :slug => "gold", :sms_slug => "gold")
    @user7 = FactoryGirl.create(:claimed_user, :name => "Latino", :demo => @demo2, :email => "four@biker.com", :slug => "nutcase", :sms_slug => "nutcase")
    @user8 = FactoryGirl.create(:claimed_user, :name => "Va Va Va Voom", :demo => @demo2, :email => "seven@biker.com", :slug => "sixpack", :sms_slug => "sixpack")
    @user9 = FactoryGirl.create(:claimed_user, :name => "Joining Now 2", :demo => @demo2, :email => "angel@biker.com", :slug => "damnation", :sms_slug => "damnation")
    
    sign_in_as @user0
  end
   
  describe "find the user named lucy that's in our game" do
    it "should return 'Lucy'" do
      @params = {:entered_text => "ucy"}
      get :index, @params
      assigns[:matched_users].length.should == 1
      assigns[:matched_users].should include @user2
    end
  end

  describe "not find the user with slug 'sixpack' that's in other game'" do
    it "should return 'sterling'" do
      @params = {:entered_text => "six"}
      get :index, @params
      assigns[:matched_users].length.should == 0
    end
  end
end
