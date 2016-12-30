require "spec_helper"

describe Assets::Filename do
  it "returns normalized filename" do
    expect(Assets::Filename.normalize("test%file 1.JPG")).to eq("test-file-1.jpg")
  end
end