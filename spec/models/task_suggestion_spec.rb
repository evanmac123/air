require 'spec_helper'

describe TaskSuggestion do
  it { should belong_to(:user) }
  it { should belong_to(:task) }
end
