require 'spec_helper'

describe Rule do
  subject { Factory(:rule) }

  it { should belong_to(:key) }
  it { should validate_uniqueness_of(:value).scoped_to(:key_id) }
end
