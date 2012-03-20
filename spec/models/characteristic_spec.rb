require 'spec_helper'

describe Characteristic do
  subject { Factory :characteristic }
  it { should belong_to :demo }
  it { should validate_uniqueness_of :name }
end
