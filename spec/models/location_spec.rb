require 'spec_helper'

describe Location do
  it { should belong_to :demo }
  it { should validate_presence_of :name }
end
