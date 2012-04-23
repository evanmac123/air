require 'spec_helper'
describe Invitation::AutocompletionsController do
  
  before do
    User.delete_all
    Demo.delete_all
    SelfInvitingDomain.delete_all
    
    @demo1 = Factory(:demo, :name => "Bratwurst")
    @demo2 = Factory(:demo, :name => "Gleason")
    @self_inviting_domain1 = Factory(:self_inviting_domain, :domain => "hopper.com", :demo => @demo1)
    @self_inviting_domain2 = Factory(:self_inviting_domain, :domain => "biker.com", :demo => @demo2)

    @user0 = Factory(:claimed_user, :name => "Joining Now 1", :demo => @demo1, :email => "angel@hopper.com", :slug => "angelfire", :sms_slug => "angelfire")
    @user1 = Factory(:claimed_user, :name => "mad house", :demo => @demo1, :email => "manly@hopper.com", :slug => "beau", :sms_slug => "beau")
    @user2 = Factory(:claimed_user, :name => "Lucy", :demo => @demo1, :email => "boob@hopper.com", :slug => "lou", :sms_slug => "lou")
    @user3 = Factory(:claimed_user, :name => "Strange", :demo => @demo1, :email => "surround@hopper.com", :slug => "think", :sms_slug => "think")
    @user4 = Factory(:claimed_user, :name => "Parking Lot", :demo => @demo1, :email => "chevo@hopper.com", :slug => "master", :sms_slug => "master")
    @user5 = Factory(:claimed_user, :name => "Lucy", :demo => @demo2, :email => "boob@biker.com", :slug => "sterling", :sms_slug => "sterling")
    @user6 = Factory(:claimed_user, :name => "Brewski", :demo => @demo2, :email => "three@biker.com", :slug => "gold", :sms_slug => "gold")
    @user7 = Factory(:claimed_user, :name => "Latino", :demo => @demo2, :email => "four@biker.com", :slug => "nutcase", :sms_slug => "nutcase")
    @user8 = Factory(:claimed_user, :name => "Va Va Va Voom", :demo => @demo2, :email => "seven@biker.com", :slug => "sixpack", :sms_slug => "sixpack")
    @user9 = Factory(:claimed_user, :name => "Joining Now 2", :demo => @demo2, :email => "angel@biker.com", :slug => "damnation", :sms_slug => "damnation")
  
  end
   
  describe "find the user named lucy that's in our game" do
    it "should return 'Lucy'" do
      @params = {:email => "angel@hopper.com", :entered_text => "ucy"}
      get :index, @params
      assigns[:matched_users].length.should == 1
      assigns[:matched_users].should include @user2
    end
  end

  describe "find the user with email biker.com that's in our game'" do
    it "should return 'sterling'" do
      @params = {:email => "angel@biker.com", :entered_text => "bik"}
      get :index, @params
      assigns[:matched_users].length.should == 4
      assigns[:matched_users].should include @user5
      assigns[:matched_users].should include @user6
      assigns[:matched_users].should include @user7
      assigns[:matched_users].should include @user8
    end
  end


  describe "find the user with slug 'sixpack' that's in our game'" do
    it "should return 'sterling'" do
      @params = {:email => "angel@biker.com", :entered_text => "six"}
      get :index, @params
      assigns[:matched_users].length.should == 1
      assigns[:matched_users].should include @user8
    end
  end
  
    # # Search for 'luc' and should return user named Lucy, but only the one from demo1
    # @returned = User.get_users_where_like('luc', @demo1, "name")
    # binding.pry unless @returned == [@user2]
    # 
    # # Search for 'hop' should return all users with 'hopper.com' email
    # @returned = User.get_users_where_like('hop', @demo1, "email")
    # binding.pry unless @returned == [@user1, @user2, @user3, @user4]
    # 
    # # Search for '' should return all users with 'hopper.com' email
    # @returned = User.get_users_where_like('boob', @demo1, "email")
    # binding.pry unless @returned == [@user1, @user2, @user3, @user4]
    #  
    # get :index, @params = {:email => @user1.email, :entered_text => 'luc'}
    # @matched_users.should == [@user2]
    # 
    # puts "WHEEEEEEEEEE!!!!! All Tests Passing!"
    
end
