require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "User Sees Only Profile In Current Demo" do
  scenario "User sees only profile in current demo" do
    @user1 = FactoryGirl.create :claimed_user
    @user2 = FactoryGirl.create :claimed_user

    @user1.demo.should_not == @user2.demo
    
    has_password @user1, "foobar"
    signin_as @user1, "foobar"
    should_be_on activity_path(:format => :html)

    visit user_path(@user2)
    page.should_not have_content(@user2.email)
    page.status_code.should == 404
  end
end
