require 'spec_helper'

describe Prerequisite do
  it { should belong_to(:suggested_task) }
  it { should belong_to(:prerequisite_task) }
end
