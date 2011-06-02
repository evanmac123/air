require 'spec_helper'

describe BonusThreshold do
  it { should validate_presence_of :threshold }
  it { should validate_presence_of :max_points }
  it { should validate_presence_of :demo_id }
end
