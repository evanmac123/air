require 'spec_helper'

describe Goal do
  it { should have_many :rules }
  it { should have_many(:acts).through(:rules) }
  it { should belong_to :demo }
  it { should validate_presence_of(:demo_id) }
  it { should validate_presence_of(:name) }
end
