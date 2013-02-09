require 'spec_helper'

describe UserCreatorFromCsv do
  let(:demo)                    {FactoryGirl.create(:demo)}
  let(:basic_schema)            {%w(name email)} # that's enough to get a user going
  let(:basic_attributes)        {["Jim Smith", "bigjim@example.com"]}
  let(:discrete_characteristic) {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DiscreteType, allowed_values: %w(foo bar baz))}
  let(:number_characteristic)   {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::NumberType)}
  let(:date_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DateType)}
  let(:time_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::TimeType)}
  let(:boolean_characteristic)  {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::BooleanType)}
 
  describe "#create_user" do
    it "should build and attempt to save a user" do
      creator = UserCreatorFromCsv.new(demo.id, basic_schema)

      demo.users.count.should be_zero
      creator.create_user(CSV.generate_line(basic_attributes))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == basic_attributes.first
      user.email.should == basic_attributes.last
    end

    it "should be able to set characteristics too" do
      schema = basic_schema.dup
      [discrete_characteristic, number_characteristic, date_characteristic, time_characteristic, boolean_characteristic].each do |characteristic|
        schema << "characteristic_#{characteristic.id}"
      end
      creator = UserCreatorFromCsv.new(demo.id, schema)

      demo.users.count.should be_zero

      attributes = basic_attributes + ["bar", "1945", "2013-02-07", "2013-02-07 18:12:51 -0500", "false"]
      creator.create_user(CSV.generate_line(attributes))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == attributes[0]
      user.email.should == attributes[1]

      user.characteristics[discrete_characteristic.id].should == "bar"
      user.characteristics[number_characteristic.id].should == 1945
      user.characteristics[date_characteristic.id].should == Date.parse("2013-02-07")
      user.characteristics[time_characteristic.id].should == Time.parse("2013-02-07 18:12:51 -0500")
      user.characteristics[boolean_characteristic.id].should == false
    end

    context "when loading characteristics" do
      context "should allow some flexibility in boolean formats" do
        %w(yes Yes Y true True t T 1).each do |true_string|
          it "such as recognizing \"#{true_string}\" as meaning true" do
            schema = basic_schema + ["characteristic_#{boolean_characteristic.id}"]
            attributes = basic_attributes + [true_string]

            creator = UserCreatorFromCsv.new(demo.id, schema)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[boolean_characteristic.id].should be_true
          end
        end

        %w(no No N false False f F 0).each do |false_string|
          it "such as recognizing \"#{false_string}\" as meaning \"false\"" do
            schema = basic_schema + ["characteristic_#{boolean_characteristic.id}"]
            attributes = basic_attributes + [false_string]

            creator = UserCreatorFromCsv.new(demo.id, schema)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[boolean_characteristic.id].should be_false
          end
        end
      end

      %w(date time).each do |characteristic_type|
        it "should allow some flexibility in #{characteristic_type} formats" do
          pending
        end
      end
    end
  end
end
