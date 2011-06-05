require 'spec_helper'

describe Level do
  subject {Factory :level}

  it { should validate_presence_of :name }
  it { should validate_presence_of :threshold }
  it { should validate_presence_of :demo_id }

  it { should validate_uniqueness_of(:threshold).scoped_to(:demo_id) }

  it { should belong_to :demo }
end
