require 'acceptance/acceptance_helper'

feature 'Admin sends targeted messges using segmentation' do
  it 'should send messages to the proper users', :js => true do
    demo = FactoryGirl.create :demo
    users = []
    20.times {|i| users << FactoryGirl.create(:user, points: i, demo: demo)}
    # Also let's make some users in a different demo to make sure we don't get
    # leakage.
    5.times {FactoryGirl.create(:user)}

    agnostic_characteristic = FactoryGirl.create(:characteristic, name: "Metasyntactic variable", allowed_values: %w(foo bar baz))
    demo_specific_characteristic = FactoryGirl.create(:characteristic, :number)

    10.upto(19) {|i| users[i].update_attributes(characteristics: {agnostic_characteristic.id.to_s => %w(foo bar baz)[i % 3], demo_specific_characteristic.id.to_s => i % 5})}
    crank_dj_clear

    signin_as_admin

    visit admin_demo_targeted_messages_path(demo)

    select 'Metasyntactic variable', :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    select "foo", :from => "segment_value[0]"

    click_link "Segment on more characteristics"
    select "Points", :from => "segment_column[1]"
    select "greater than", :from => "segment_operator[1]"
    fill_in "segment_value[1]", :with => "10"

    click_button "Find segment"

    should_be_on(admin_demo_targeted_messages_path(demo))
    expect_content "6 users in segment"
    expect_content "Segmenting on: Metasyntactic variable does not equal foo, Points is greater than 10"
    expected_users = [11, 13, 14, 16, 17, 19].map{|i| users[i]}

    fill_in "subject", :with => "Did you know?"
    fill_in "html-text", :with => "<p>Hello friends!</p><p>H Engage is awesome.</p>"

    click_button "DO IT"
    expect_content "Scheduled messages to 6 users"

    crank_dj_clear
    ActionMailer::Base.deliveries.length.should == 6
    pending
  end

  it 'should allow preview of emails'

  it 'should allow preview of texts'

  it "should allow drafts to be saved"

  it 'should allow a communication to be tracked after the fact'

  it 'should respect notification preferences by default' do
    pending
  end

  it 'should allow override of notification preferences and send to everyone possible' do
    pending
  end

  it "should have a link from somewhere in the admin side"

  it "should have an optional plaintext override field"

  it "should automatically compose a plaintext version"
end
