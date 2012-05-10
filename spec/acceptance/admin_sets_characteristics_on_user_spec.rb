require File.expand_path(File.dirname(__FILE__) + '/acceptance_helper')

feature "Admin Sets Characteristics On User" do

  scenario "should allow both generic and demo-specific characteristics to be set" do
    @demo = FactoryGirl.create :demo
    @generic_characteristic = FactoryGirl.create :characteristic, :name => 'generic', :allowed_values => %w(foo bar baz)
    @demo_characteristic = FactoryGirl.create :characteristic, :demo_specific, :name => 'demo specific', :allowed_values => %w(oh hai dere), :demo => @demo
    @number_characteristic = FactoryGirl.create :characteristic, :demo_specific, :name => 'number type', :datatype => Characteristic::NumberType, :demo => @demo
    @date_characteristic = FactoryGirl.create :characteristic, :demo_specific, :name => 'date type', :datatype => Characteristic::DateType, :demo => @demo
    @boolean_characteristic = FactoryGirl.create :characteristic, :demo_specific, :name => 'boolean type', :datatype => Characteristic::BooleanType, :demo => @demo
    @other_demo_characteristic = FactoryGirl.create :characteristic, :demo_specific, :name => 'other demo characteristic', :allowed_values => %w(and so on)
    @user = FactoryGirl.create :user, :demo => @demo, :name => "Hank Robertson"

    signin_as_admin
    visit edit_admin_demo_user_path(@user.demo, @user)
    expect_no_content('other demo characteristic')

    select 'bar', :from => 'generic'
    select 'hai', :from => 'demo specific'
    fill_in 'number type', :with => '666'
    fill_in 'date type', :with => "March 1, 2010"
    check 'boolean type'
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
    expect_value('number type', '666.0')
    expect_value('date type', '2010-03-01')
    expect_checked('boolean type')
  end
end
