require 'spec_helper'

describe Trigger::SurveyTrigger do
  it { should belong_to(:survey) }
  it { should belong_to(:suggested_task) }
end
