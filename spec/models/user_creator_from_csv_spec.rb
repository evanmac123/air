require 'spec_helper'

describe UserCreatorFromCsv do
  let(:demo)                    {FactoryGirl.create(:demo)}

  let(:basic_schema)                {%w(name email)} # that's enough to get a user going
  let(:schema_with_characteristics) do
    schema = basic_schema.dup
    [discrete_characteristic, number_characteristic, date_characteristic, time_characteristic, boolean_characteristic].each do |characteristic|
      schema << "characteristic_#{characteristic.id}"
    end
    schema
  end

  let(:basic_attributes)                {["Jim Smith", "bigjim@example.com"]}
  let(:attributes_with_characteristics) {basic_attributes + ["bar", "1945", "2013-02-07", "2013-02-07 18:12:51 -0500", "false"]}

  let(:discrete_characteristic) {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DiscreteType, allowed_values: %w(foo bar baz))}
  let(:number_characteristic)   {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::NumberType)}
  let(:date_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DateType)}
  let(:time_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::TimeType)}
  let(:boolean_characteristic)  {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::BooleanType)}
 
  describe "#create_user" do
    it "should build and attempt to save a user" do
      creator = UserCreatorFromCsv.new(demo.id, basic_schema, :email)

      demo.users.count.should be_zero
      creator.create_user(CSV.generate_line(basic_attributes))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == basic_attributes.first
      user.email.should == basic_attributes.last
    end

    it "should update existing users should there be any" do
      demo.users.create!(name: "Jim Robinson", email: "bigjim@example.com")
      creator = UserCreatorFromCsv.new(demo.id, basic_schema, :email) # email is the "unique ID" when loading
      creator.create_user(CSV.generate_line(basic_attributes))

      demo.users.reload.count.should == 1 # as opposed to 2
      user = demo.users.first
      user.name.should == basic_attributes.first
      user.email.should == basic_attributes.last
    end

    it "should not overwrite characteristics for an existing user, when those characteristics are not in the schema" do
      # lose the boolean characteristic      
      schema_with_most_characteristics = schema_with_characteristics.dup
      schema_with_most_characteristics.pop 
      attributes_with_most_characteristics = attributes_with_characteristics.dup
      attributes_with_most_characteristics.pop

      creator = UserCreatorFromCsv.new(demo.id, schema_with_most_characteristics, :email)

      user = FactoryGirl.create(
        :user, 
        demo:  demo, 
        email: 'bigjim@example.com',
        characteristics: {
          number_characteristic.id  =>  999,
          boolean_characteristic.id => false
        }
      )

      creator.create_user(CSV.generate_line(attributes_with_most_characteristics))

      demo.users.reload.count.should == 1
      user.reload

      user.characteristics[number_characteristic.id].should == 1945
      user.characteristics[boolean_characteristic.id].should == false # be_false returns true even when it's nil, wtf?
    end

    it "should be able to set characteristics too" do
      creator = UserCreatorFromCsv.new(demo.id, schema_with_characteristics, :email)

      demo.users.count.should be_zero

      creator.create_user(CSV.generate_line(attributes_with_characteristics))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == attributes_with_characteristics[0]
      user.email.should == attributes_with_characteristics[1]

      user.characteristics[discrete_characteristic.id].should == "bar"
      user.characteristics[number_characteristic.id].should == 1945
      user.characteristics[date_characteristic.id].should == Date.parse("2013-02-07")
      user.characteristics[time_characteristic.id].should == Time.parse("2013-02-07 18:12:51 -0500")
      user.characteristics[boolean_characteristic.id].should == false
    end

    it "should allow locations to be set by name" do
      schema = basic_schema + ['location_name']
      boston_location = FactoryGirl.create(:location, demo: demo, name: 'Boston')
      attributes = basic_attributes + ['Boston']

      creator = UserCreatorFromCsv.new(demo.id, schema, :email)

      demo.users.count.should be_zero

      creator.create_user(CSV.generate_line(attributes))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == attributes[0]
      user.email.should == attributes[1]
      user.location.should == boston_location
    end

    it "should create locations on the fly if need be" do
      schema = basic_schema + ['location_name']
      attributes = basic_attributes + ['Boston']

      creator = UserCreatorFromCsv.new(demo.id, schema, :email)

      demo.users.count.should be_zero
      demo.locations.count.should be_zero

      creator.create_user(CSV.generate_line(attributes))

      demo.users.reload.count.should == 1
      demo.locations.reload.count.should == 1

      user = demo.users.first
      user.name.should == attributes[0]
      user.email.should == attributes[1]
      user.location.should == demo.locations.first
    end

    def expect_attribute_flexibility(attribute_name, attribute_value, expected_model_value)
      schema = basic_schema + [attribute_name]
      attributes = basic_attributes + [attribute_value]

      creator = UserCreatorFromCsv.new(demo.id, schema, :email)
      creator.create_user(CSV.generate_line(attributes))

      demo.users.first[attribute_name].should == expected_model_value
    end

    context "should parse date of birth with some flexibility" do
      ["1977-09-10", "1977/09/10", "9/10/1977", "9-10-1977", "Sep 10, 1977", "Sep 10 1977"].each do |date_string|
        it "such as parsing #{date_string} as September 10, 1977" do
          expect_attribute_flexibility('date_of_birth', date_string, Date.parse('1977-09-10'))
        end
      end
    end

    context "should parse gender with some flexibility" do
      %w(male Male M m).each do |male_string|
        it "such as interpreting #{male_string} as male" do
          expect_attribute_flexibility('gender', male_string, 'male')
        end
      end

      %w(female Female F f).each do |female_string|
        it "such as interpreting #{female_string} as female" do
          expect_attribute_flexibility('gender', female_string, 'female')
        end
      end

      %w(other Other o O).each do |other_string|
        it "such as interpreting #{other_string} as other" do
          expect_attribute_flexibility('gender', other_string, 'other')
        end
      end
    end

    context "when loading characteristics" do
      context "should allow some flexibility in boolean formats" do
        %w(yes Yes Y true True t T 1).each do |true_string|
          it "such as recognizing \"#{true_string}\" as meaning true" do
            schema = basic_schema + ["characteristic_#{boolean_characteristic.id}"]
            attributes = basic_attributes + [true_string]

            creator = UserCreatorFromCsv.new(demo.id, schema, :email)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[boolean_characteristic.id].should be_true
          end
        end

        %w(no No N false False f F 0).each do |false_string|
          it "such as recognizing \"#{false_string}\" as meaning \"false\"" do
            schema = basic_schema + ["characteristic_#{boolean_characteristic.id}"]
            attributes = basic_attributes + [false_string]

            creator = UserCreatorFromCsv.new(demo.id, schema, :email)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[boolean_characteristic.id].should be_false
          end
        end
      end

      context "should allow some flexibility in date formats" do
        ["2012-05-01", "2012/05/01", "5/1/2012", "5-1-2012", "May 1, 2012", "May 1 2012"].each do |date_string|
          it "such as recognizing \"#{date_string}\" as meaning May 1, 2012" do
            schema = basic_schema + ["characteristic_#{date_characteristic.id}"]
            attributes = basic_attributes + [date_string]

            creator = UserCreatorFromCsv.new(demo.id, schema, :email)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[date_characteristic.id].should == Date.parse("2012-05-01")
          end
        end
      end
    end
  end
end
