require 'spec_helper'

describe Trigger::DemographicTrigger do
  it { should belong_to :task }
end
