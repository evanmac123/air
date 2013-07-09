require 'spec_helper'

describe TileBuilderForm::Keyword do
  it "should have a reasonable model_name" do
    TileBuilderForm::Keyword.model_name.should == 'TileBuilderForm'
  end

  it "should tell a white lie about its persisted status to keep form_for happy" do
    TileBuilderForm::Keyword.new(nil).persisted?.should be_false
  end
end
