require "spec_helper"

describe Assets::Filename do
  it "returns normalized filename" do
    Assets::Filename.normalize("test%file 1.JPG").should == "test-file-1.jpg"
  end
end