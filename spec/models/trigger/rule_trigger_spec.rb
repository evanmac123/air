require 'spec_helper'

describe Trigger::RuleTrigger do
  it { should belong_to :tile }
  it { should belong_to :rule }

  it "should set referrer_required to false by default" do
    trigger = Trigger::RuleTrigger.new
    trigger.save.should be_true
    trigger.reload
    trigger.referrer_required.should be_false
  end
end
