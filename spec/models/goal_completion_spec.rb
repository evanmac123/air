require 'spec_helper'

describe GoalCompletion do
  it { should belong_to(:goal) }
  it { should belong_to(:user) }
end
