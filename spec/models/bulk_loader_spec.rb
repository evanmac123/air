require 'spec_helper'

describe BulkLoader do
  def expect_user(attributes)
    User.where(attributes).length.should == 1
  end

  context "with a custom schema" do
    let(:custom_schema) do
      [
        :date_of_birth,
        :email,
        [:sms_slug, {do_after_save: true}],
        :zip_code,
        :name,
        :claim_code,
        :gender
      ]
    end

    let(:demo) {FactoryGirl.create(:demo)}

    it "should load users with the correct information" do
      user_csv = <<-END_CSV_WITHOUT_CHARACTERISTICS
2007-08-04,bob@bobco.mil,bobbi,02139,Bob Bobson,bobbyjoe,male
1994-04-17,jim@jimmery.com,jim,94110,Jim Jimmerson,jimmy,other
      END_CSV_WITHOUT_CHARACTERISTICS

      successful_creations, errored_users = BulkLoader.new(demo, user_csv, {}, custom_schema).bulk_load!

      successful_creations.should == 2
      User.count.should == 2
      errored_users.should be_empty

      expect_user(
        date_of_birth: Date.parse("2007-08-04"),
        email:         "bob@bobco.mil",
        sms_slug:      "bobbi",
        zip_code:      "02139",
        name:          "Bob Bobson",
        claim_code:    "bobbyjoe",
        gender:        "male"
      )

      expect_user(
        date_of_birth: Date.parse("1994-04-17"),
        email:         "jim@jimmery.com",
        sms_slug:      "jim",
        zip_code:      "94110",
        name:          "Jim Jimmerson",
        claim_code:    "jimmy",
        gender:        "other"
      )
    end

    context "and characteristics too" do
      it "should load users with the correct information and the characteristics as well" do
        discrete_characteristic = FactoryGirl.create(:characteristic, :discrete, :name => "T-shirt size", :allowed_values => %w(S M L XL))
        numerical_characteristic = FactoryGirl.create(:characteristic, :number, :name => "Brain size")

        user_csv = <<-END_CSV_WITH_CHARACTERISTICS
  2007-08-04,bob@bobco.mil,bobbi,02139,Bob Bobson,bobbyjoe,male,14.6,S
  1994-04-17,jim@jimmery.com,jim,94110,Jim Jimmerson,jimmy,other,,XL
        END_CSV_WITH_CHARACTERISTICS

        characteristic_data = {
          "7" => numerical_characteristic.id.to_s,
          "8" => discrete_characteristic.id.to_s
        }

        successful_creations, errored_users = BulkLoader.new(demo, user_csv, characteristic_data, custom_schema).bulk_load!

        successful_creations.should == 2
        User.count.should == 2
        errored_users.should be_empty

        expect_user(
          date_of_birth: Date.parse("2007-08-04"),
          email:         "bob@bobco.mil",
          sms_slug:      "bobbi",
          zip_code:      "02139",
          name:          "Bob Bobson",
          claim_code:    "bobbyjoe",
          gender:        "male"
        )

        expect_user(
          date_of_birth: Date.parse("1994-04-17"),
          email:         "jim@jimmery.com",
          sms_slug:      "jim",
          zip_code:      "94110",
          name:          "Jim Jimmerson",
          claim_code:    "jimmy",
          gender:        "other"
        )

        User.find_by_name("Bob Bobson").characteristics.should == {discrete_characteristic.id => 'S', numerical_characteristic.id => 14.6}
        User.find_by_name("Jim Jimmerson").characteristics.should == {discrete_characteristic.id => 'XL'}
      end
    end
  end
end
