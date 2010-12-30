require 'spec_helper'

describe Demo do
  it { should have_many(:players) }
end

describe Demo, ".alphabetical" do
  before do
    @red_sox  = Factory(:demo, :company_name => "Red Sox")
    @gillette = Factory(:demo, :company_name => "Gillette")
  end

  it "finds all demos, sorted alphaetically" do
    Demo.alphabetical.should == [@gillette, @red_sox]
  end
end
