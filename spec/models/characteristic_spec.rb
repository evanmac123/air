require 'spec_helper'

describe Characteristic do
  subject { FactoryGirl.create :characteristic }
  it { is_expected.to belong_to :demo }
  it { is_expected.to validate_uniqueness_of :name }
end
