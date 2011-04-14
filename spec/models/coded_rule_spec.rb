require 'spec_helper'

describe CodedRule do
  it { should validate_presence_of(:description) }
end
