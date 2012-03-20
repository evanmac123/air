require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Sets Characteristics On User" do

  scenario "should allow both generic and demo-specific characteristics to be set" do
    @demo = Factory :demo
    @generic_characteristic = Factory :characteristic, :name => 'generic', :allowed_values => %w(foo bar baz)
    @demo_characteristic = Factory :demo_specific_characteristic, :name => 'demo specific', :allowed_values => %w(oh hai dere), :demo => @demo
    @other_demo_characteristic = Factory :demo_specific_characteristic, :name => 'other demo characteristic', :allowed_values => %w(and so on)
    @user = Factory :user, :demo => @demo, :name => "Hank Robertson"

    signin_as_admin
    visit edit_admin_demo_user_path(@user.demo, @user)
    expect_no_content('other demo characteristic')

    select 'bar', :from => 'generic'
    select 'hai', :from => 'demo specific'
    click_button "Set characteristics"

    should_be_on edit_admin_demo_user_path(@user.demo, @user)
    expect_content("Characteristics for Hank Robertson updated")
    expect_selected('generic', 'bar')
    expect_selected('demo specific', 'hai')

    select '', :from => 'generic'
    select 'oh', :from => 'demo specific'
    click_button "Set characteristics"

    should_be_on edit_admin_demo_user_path(@user.demo, @user)
    expect_content("Characteristics for Hank Robertson updated")
    expect_no_option_selected('generic')
    expect_selected('demo specific', 'oh')
  end
end
