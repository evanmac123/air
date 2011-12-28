require 'spec_helper'

describe SuggestedTask do
  it { should belong_to(:demo) }
  it { should have_many(:prerequisites) }
  it { should have_many(:prerequisite_tasks) }
  it { should have_many(:rule_triggers) }
  it { should have_one(:survey_trigger) }
end
