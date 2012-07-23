require 'spec_helper'

describe "InvitationEmail" do

  it "has bullet defaults" do
    InvitationEmail.bullet_defaults.class.should == Hash
    InvitationEmail.bullet_defaults.length.should == 6
  end

  it "selects either the default text or the demo-specific text" do
    User.delete_all
    Demo.delete_all
    @monopoly = FactoryGirl.create(:demo)
    @lucy = FactoryGirl.create(:user, demo: @monopoly)
    appends = ['1a', '1b', '2a', '2b', '3a', '3b']
    # First with a generic demo (no custom fields set)
    appends.each do |append|
      default_text = InvitationEmail.bullet_defaults[append]
      demo_specific_text = eval("InvitationEmail.bullet_#{append}(@lucy)")
      demo_specific_text.should == default_text
    end
    
    # Now set custom appends
    appends.each do |append|
      eval "@monopoly.invitation_bullet_#{append} = append"
    end

    @monopoly.save!

    appends.each do |append|
      demo_specific_text = eval("InvitationEmail.bullet_#{append}(@lucy)")
      demo_specific_text.should == append
    end
   
  end
end
