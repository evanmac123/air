require 'spec_helper'

describe Key do
  subject { Factory(:key) }

  it { should have_many(:rules) }

  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name) }
end
