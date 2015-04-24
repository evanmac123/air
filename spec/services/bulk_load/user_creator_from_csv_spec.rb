require 'spec_helper'

describe BulkLoad::UserCreatorFromCsv do
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

  let(:basic_creator) {BulkLoad::UserCreatorFromCsv.new(demo.id, basic_schema, :email, 1)}
  let(:discrete_characteristic) {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DiscreteType, allowed_values: %w(foo bar baz))}
  let(:number_characteristic)   {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::NumberType)}
  let(:date_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::DateType)}
  let(:time_characteristic)     {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::TimeType)}
  let(:boolean_characteristic)  {FactoryGirl.create(:characteristic, demo: demo, datatype: Characteristic::BooleanType)}
 
  describe "#create_user" do
    it "should build and attempt to save a user" do
      demo.users.count.should be_zero
      basic_creator.create_user(CSV.generate_line(basic_attributes))

      demo.users.reload.count.should == 1
      user = demo.users.first
      user.name.should == basic_attributes.first
      user.email.should == basic_attributes.last
    end

    context "for an existing user" do
      it "should update them" do
        demo.users.create!(name: "Jim Robinson", email: "bigjim@example.com")
        basic_creator.create_user(CSV.generate_line(basic_attributes))

        demo.users.reload.count.should == 1 # as opposed to 2
        user = demo.users.first
        user.name.should == basic_attributes.first
        user.email.should == basic_attributes.last
      end

      it "should not overwrite their characteristics, when those characteristics are not in the schema" do
        # lose the boolean characteristic      
        schema_with_most_characteristics = schema_with_characteristics.dup
        schema_with_most_characteristics.pop 
        attributes_with_most_characteristics = attributes_with_characteristics.dup
        attributes_with_most_characteristics.pop

        creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema_with_most_characteristics, :email, 1)

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

      it "should not try to set an email from the census, if the email in the census is in the user's overflow email, but should set the rest of the attributes" do
        user = FactoryGirl.create(:user, demo: demo, employee_id: "12345", email: "jimmy@gmail.com", overflow_email: "bigjim@example.com")

        schema = basic_schema + ['employee_id']
        attributes = basic_attributes + ['12345']
        creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :employee_id, 2)

        creator.create_user(CSV.generate_line(attributes))

        demo.users.reload.count.should == 1 # as opposed to 2

        user.reload
        user.email.should == "jimmy@gmail.com"
        user.overflow_email.should == "bigjim@example.com"
        user.name.should == "Jim Smith"
      end
    end

    it "should be able to set characteristics too" do
      creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema_with_characteristics, :email, 1)

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

      creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)

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

      creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)

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

    context "when using email as the unique ID" do
      it "should downcase email in the input before trying to locate a user based on it" do
        user = FactoryGirl.create(:user, name: "John Q. Doe", email: "john@doe.com")
        user.add_board(demo)
        demo.users.count.should == 1

        creator = BulkLoad::UserCreatorFromCsv.new(demo.id, basic_schema, :email, 1)
        creator.create_user(CSV.generate_line(["John Doe", 'John@DoE.cOm']))

        demo.users.count.should == 1
        found_user = demo.users.first
        found_user.name.should == 'John Doe'
        found_user.email.should == 'john@doe.com'
      end
    end

    shared_examples_for "ignoring a match in another board" do
      it "should not add that user to this board" do
        @other_user.reload.demo_ids.should have(1).board_id
        @other_user.demo_ids.first.should_not == demo.id
      end

      it "should not try to update that user" do
        @other_user.reload
        @other_user.name.should == 'John Doe'
        @other_user.email.should == 'john@doe.com'
        @other_user.employee_id.should == '12345'
      end

      it "should try to create a separate user in the board we're loading into" do
        new_user = demo.users.find_by_employee_id('12345')
        new_user.demo_ids.should == [demo.id]
        new_user.name.should == 'John Smith'
        new_user.email.should == 'john@smith.com'
        new_user.employee_id.should == '12345'
      end
    end

    context "when there is a user matching that unique ID in another board" do
      before do
        @other_user = FactoryGirl.create(:user, name: "John Doe", email: "john@doe.com", employee_id: '12345')

        @schema = %w(name email employee_id)
        @csv = CSV.generate_line(["John Smith", "john@smith.com", "12345"])
      end

      context "by default" do
        before do
          creator = BulkLoad::UserCreatorFromCsv.new(demo.id, @schema, :employee_id, 2)
          creator.create_user(@csv)
        end

        it_should_behave_like "ignoring a match in another board"
      end

      context "when we have a list of alternate board IDs, but that user isn't in one of them" do
        before do
          other_boards = FactoryGirl.create_list(:demo, 3)
          other_board_ids = other_boards.map(&:id)
          creator = BulkLoad::UserCreatorFromCsv.new(demo.id, @schema, :employee_id, 2, other_board_ids)
          creator.create_user(@csv)
        end

        it_should_behave_like "ignoring a match in another board"
      end

      context "when we have a list of alternate board IDs, and that user is in one of them" do
        before do
          other_boards = FactoryGirl.create_list(:demo, 3)
          other_board_ids = other_boards.map(&:id) + @other_user.demo_ids
          creator = BulkLoad::UserCreatorFromCsv.new(demo.id, @schema, :employee_id, 2, other_board_ids)
          creator.create_user(@csv)
        end

        it "should add them to the board we're loading into" do
          @other_user.reload.demo_ids.should have(2).ids
          @other_user.demo_ids.should include(demo.id)
        end

        it "should update them" do
          @other_user.reload
          @other_user.name.should == 'John Smith'
          @other_user.email.should == 'john@smith.com'
          @other_user.employee_id.should == '12345'
        end

        it "should not try to create a separate user" do
          demo.user_ids.should include(@other_user.id)
        end
      end
    end

    def expect_attribute_flexibility(attribute_name, attribute_value, expected_model_value)
      schema = basic_schema + [attribute_name]
      attributes = basic_attributes + [attribute_value]

      creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)
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

            creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[boolean_characteristic.id].should be_true
          end
        end

        %w(no No N false False f F 0).each do |false_string|
          it "such as recognizing \"#{false_string}\" as meaning \"false\"" do
            schema = basic_schema + ["characteristic_#{boolean_characteristic.id}"]
            attributes = basic_attributes + [false_string]

            creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)
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

            creator = BulkLoad::UserCreatorFromCsv.new(demo.id, schema, :email, 1)
            creator.create_user(CSV.generate_line(attributes))

            demo.users.first.characteristics[date_characteristic.id].should == Date.parse("2012-05-01")
          end
        end
      end
    end
  end
end
