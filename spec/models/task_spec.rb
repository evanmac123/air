require 'spec_helper'

describe Task do
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
      task = Factory :task, :demo => demo
      Factory :task_suggestion, :user => user1, :task => task

      user1.task_suggestions.count.should == 1
      user2.task_suggestions.count.should == 0

      task.send(:suggest_to_eligible_users)

      user1.reload.task_suggestions.count.should == 1
      user2.reload.task_suggestions.count.should == 1
    end
  end
  
  describe "#due?" do
    it "should tell me whether a task is within the window of opportunity" do
      demo = Factory.build :demo
      a = Factory.build :task, :demo => demo
      a.update_attribute('start_time', nil)
      a.update_attribute('end_time', nil)
      a.should be_due
      a.update_attribute('start_time', 1.minute.ago)
      a.should be_due
      a.update_attribute('start_time', 1.minute.from_now)
      a.should_not be_due      
      a.update_attribute('end_time', 1.minute.from_now)
      a.should_not be_due
      a.update_attribute('start_time', 1.minute.ago)
      a.update_attribute('end_time', 1.minute.ago)
      a.should_not be_due
      a.update_attribute('end_time', 1.minute.from_now)
      a.should be_due
      
    end
  end
  
  
end
