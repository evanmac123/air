require 'spec_helper'

describe Trigger::RuleTrigger do
  it { should belong_to :suggested_task }
  it { should belong_to :rule }
end
