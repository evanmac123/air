require 'spec_helper'

describe User::SegmentationOperator do
  describe ".find_by_name" do
    {
      "equals"         => User::EqualsOperator,
      "does not equal" => User::NotEqualsOperator
    }.each do |operator_name, expected_class|
      it "should return #{expected_class} when called with \"#{operator_name}\"" do
        expect(User::SegmentationOperator.find_by_name(operator_name)).to eq(expected_class)
      end
    end

    context "with an invalid name" do
      it "should raise an error" do
        expect{User::SegmentationOperator.find_by_name('julienne')}.to raise_error(User::SegmentationOperatorError)
      end
    end
  end
end

all_types = [Characteristic::DiscreteType, Characteristic::NumberType, Characteristic::BooleanType]
continuous_types = [Characteristic::NumberType, Characteristic::DateType]
discrete_types =[Characteristic::DiscreteType, Characteristic::BooleanType]

values_for_comparison = {
  Characteristic::DiscreteType => %w(1 10 100),
  Characteristic::NumberType   => [1, 10, 100],
  Characteristic::DateType     => ["January 1, 1999", "March 4, 2003", "May 1, 2012"].map{|datestring| Chronic.parse(datestring)},
  Characteristic::BooleanType  => [false, true, false]
}

all_types.each do |type|
  {
    User::EqualsOperator => [false, true, false],
    User::NotEqualsOperator => [true, false, true]
  }.each do |operator_class, match_senses|
    describe "#{operator_class} applied to #{type}" do
      it "should match the appropriate values" do
        characteristic = FactoryBot.create(:characteristic, :datatype => type)

        low, exact, high = values_for_comparison[type]

        low_record = User::SegmentationData.create("characteristics" => {characteristic.id.to_s => low})
        exact_record = User::SegmentationData.create("characteristics" => {characteristic.id.to_s => exact})
        high_record = User::SegmentationData.create("characteristics" => {characteristic.id.to_s => high})

        expect(User::SegmentationData.count).to eq(3)

        query_result = operator_class.new([exact]).add_criterion_to_query(User::SegmentationData, characteristic.id.to_s).all
        [low_record, exact_record, high_record].each_with_index do |record, index|
          if match_senses[index]
            expect(query_result).to include(record)
          else
            expect(query_result).not_to include(record)
          end
        end
      end
    end
  end
end

def attempt_application(operator_class, applicable_type)
  operator_class.add_criterion_to_query(User::SegmentationData, FactoryBot.create(:characteristic, :datatype => applicable_type).id, operator_class.human_name)
end

def expect_applicable_to(operator_class, applicable_type)
  expect{ attempt_application(operator_class, applicable_type)  }.not_to raise_error
end

def expect_not_applicable_to(operator_class, applicable_type)
  expect{ attempt_application(operator_class, applicable_type)  }.to raise_error(User::NonApplicableSegmentationOperatorError)
end

{
  User::EqualsOperator    => all_types,
  User::NotEqualsOperator => all_types
}.each do |operator_class, applicable_types|
  describe operator_class do
    applicable_types.each do |applicable_type|
      it "should be applicable to #{applicable_type}" do
        expect_applicable_to(operator_class, applicable_type)
      end
    end
  end
end

[User::LessThanOperator, User::LessThanOrEqualOperator, User::GreaterThanOperator, User::GreaterThanOrEqualOperator].each do |continuous_operator_class|
  describe continuous_operator_class do
    continuous_types.each do |continuous_type|
      it "should be applicable to #{continuous_type}" do
        expect_applicable_to(continuous_operator_class, continuous_type)
      end
    end

    discrete_types.each do |discrete_type|
      it "should not be applicable to #{discrete_type}" do
        expect_not_applicable_to(continuous_operator_class, discrete_type)
      end
    end
  end
end
