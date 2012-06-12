require 'acceptance/acceptance_helper'

feature 'Admin sends targeted messges using segmentation' do
  it 'should send messages to the proper users', :js => true do
    demo = FactoryGirl.create :demo
    users = []
    20.times {|i| users << FactoryGirl.create(:user, points: i, demo: demo)}

    agnostic_characteristic = FactoryGirl.create(:characteristic, allowed_values: %w(foo bar baz))
    demo_specific_characteristic = FactoryGirl.create(:characteristic, :number)

    10.upto(19) {|i| users[i].update_attributes(characteristics: {agnostic_characteristic.id.to_s => %w(foo bar baz)[i % 3], demo_specific_characteristic.id.to_s => i % 5})}
    crank_dj_clear

    signin_as_admin

    visit admin_demo_targeted_messages_path(demo)
    select agnostic_characteristic.name, :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    select "foo", :from => "segment_value[0]"
    click_button "Find segment"

    should_be_on(admin_demo_targeted_messages_path(demo))
    pending
  end

  it 'should allow preview of emails'

  it 'should allow preview of texts'

  it 'should allow a communication to be tracked after the fact'

  it 'should respect notification preferences by default' do
    pending
  end

  it 'should allow override of notification preferences and send to everyone possible' do
    pending
  end
end
