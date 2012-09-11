require 'spec_helper'

describe Prerequisite do
  it { should belong_to(:tile) }
  it { should belong_to(:prerequisite_tile) }
end
