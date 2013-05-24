require 'spec_helper'

describe TileBuilderForm do
  it "should have a reasonable model_name" do
    TileBuilderForm.model_name.should == 'TileBuilderForm'
  end

  it "should tell a white lie about its persisted status to keep form_for happy" do
    TileBuilderForm.new(nil).persisted?.should be_false
  end
end
