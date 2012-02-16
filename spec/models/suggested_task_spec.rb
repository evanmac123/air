require 'ruby-debug'
require 'spec_helper'

describe SuggestedTask do
  it { should belong_to(:demo) }
  it { should have_many(:prerequisites) }
  it { should have_many(:prerequisite_tasks) }
  it { should have_many(:rule_triggers) }
  it { should have_one(:survey_trigger) }

  describe "#suggest_to_eligible_users" do
    it "should not add redundant task suggestions to users who already have this task" do
      demo = Factory :demo
      user1 = Factory :user, :demo => demo
      user2 = Factory :user, :demo => demo
      suggested_task = Factory :suggested_task, :demo => demo
      Factory :task_suggestion, :user => user1, :suggested_task => suggested_task

      user1.task_suggestions.count.should == 1
      user2.task_suggestions.count.should == 0

      suggested_task.send(:suggest_to_eligible_users)

      user1.reload.task_suggestions.count.should == 1
      user2.reload.task_suggestions.count.should == 1
    end
  end
end
