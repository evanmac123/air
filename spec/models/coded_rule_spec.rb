require 'spec_helper'

describe CodedRule do
  it { should_not validate_presence_of(:key_id) }
  it { should validate_presence_of(:description) }
end
