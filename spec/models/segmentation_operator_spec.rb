require 'spec_helper'

describe User::SegmentationOperator do
  describe ".find_by_name" do
    {
      "equals"         => User::EqualsOperator,
      "does not equal" => User::NotEqualsOperator
    }.each do |operator_name, expected_class|
      it "should return #{expected_class} when called with \"#{operator_name}\"" do
        User::SegmentationOperator.find_by_name(operator_name).should == expected_class
      end
    end

    context "with an invalid name" do
      it "should raise an error" do
        lambda{User::SegmentationOperator.find_by_name('julienne')}.should raise_error(User::SegmentationOperatorError)
      end
    end
  end
end

{
  User::EqualsOperator => [false, true, false],
  User::NotEqualsOperator => [true, false, true]
}.each do |operator_class, match_senses|
  describe operator_class do
    it "should match the appropriate values" do
      low = "1"
      exact = "10"
      high = "100"

      low_record = User::SegmentationData.create("characteristics" => {"1" => low})
      exact_record = User::SegmentationData.create("characteristics" => {"1" => exact})
      high_record = User::SegmentationData.create("characteristics" => {"1" => high})

      User::SegmentationData.count.should == 3

      query_result = operator_class.new([exact]).add_criterion_to_query(User::SegmentationData, '1').all
      [low_record, exact_record, high_record].each_with_index do |record, index|
        if match_senses[index]
          query_result.should include(record)
        else
          query_result.should_not include(record)
        end
      end
    end
  end
end

all_types = [Characteristic::DiscreteType, Characteristic::NumberType, Characteristic::DateType, Characteristic::BooleanType]
continuous_types = [Characteristic::NumberType, Characteristic::DateType]
discrete_types =[Characteristic::DiscreteType, Characteristic::BooleanType]

{
  User::EqualsOperator    => all_types,
  User::NotEqualsOperator => all_types
}.each do |operator_class, applicable_types|
  describe operator_class do
    applicable_types.each do |applicable_type|
      it "should be applicable to #{applicable_type}" do
        lambda{ operator_class.add_criterion_to_query(User::SegmentationData, Factory(:characteristic).id, operator_class.human_name) }.should_not raise_error
      end
    end
  end
end

%w(User::LessThanOperator, User::LessThanOrEqualOperator, User::GreaterThanOperator, User::GreaterThanOrEqualOperator).each do |continuous_operator|
  describe continuous_operator do
    discrete_types.each do |discrete_type|
      it "should not be applicable to #{discrete_type}"
    end
  end
end
