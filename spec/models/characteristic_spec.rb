require 'spec_helper'

describe Characteristic do
  subject { FactoryGirl.create :characteristic }
  it { should belong_to :demo }
  it { should validate_uniqueness_of :name }
end
