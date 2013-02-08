require 'spec_helper'

describe UserCreatorFromCsv do
  let(:demo)    {FactoryGirl.create(:demo)}

  describe "#create_user" do
    it "should build and attempt to save a user" do
      schema = %w(name email) # that's enough to get a user going
      creator = UserCreatorFromCsv.new(demo.id, schema)

      demo.users.count.should be_zero
      creator.create_user(CSV.generate_line(["Jim Smith", "bigjim@example.com"]))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == "Jim Smith"
      user.email.should == "bigjim@example.com"
    end

    it "should be able to set characteristics too" do
      discrete_characteristic = FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DiscreteType, allowed_values: %w(foo bar baz))
      number_characteristic = FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::NumberType)
      date_characteristic = FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DateType)
      time_characteristic = FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::TimeType)
      boolean_characteristic = FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::BooleanType)
      
      schema = %w(name email)
      [discrete_characteristic, number_characteristic, date_characteristic, time_characteristic, boolean_characteristic].each do |characteristic|
        schema << "characteristic_#{characteristic.id}"
      end
      creator = UserCreatorFromCsv.new(demo.id, schema)

      demo.users.count.should be_zero
      creator.create_user(CSV.generate_line(["Jim Smith", "bigjim@example.com", "bar", "1945", "2013-02-07", "2013-02-07 18:12:51 -0500", "false"]))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == "Jim Smith"
      user.email.should == "bigjim@example.com"

      user.characteristics[discrete_characteristic.id].should == "bar"
      user.characteristics[number_characteristic.id].should == 1945
      user.characteristics[date_characteristic.id].should == Date.parse("2013-02-07")
      user.characteristics[time_characteristic.id].should == Time.parse("2013-02-07 18:12:51 -0500")
      user.characteristics[boolean_characteristic.id].should == false
    end

    %w(date time boolean).each do |characteristic_type|
      it "should allow some flexibility in #{characteristic_type} formats" do
        pending
      end
    end
  end
end
