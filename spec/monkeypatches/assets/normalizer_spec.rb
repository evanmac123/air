require "spec_helper"

describe Assets::Normalizer do
  include ActionDispatch::TestProcess

  class FakeImage #< Sinatra::Base
    #has_attached_file :attachment
  end

  it "normalizes filename" do
    FakeImage.any_instance.stubs(:save_attached_files).returns(true)
    Paperclip::Attachment.any_instance.stubs(:post_process).returns(true)

    FakeImage.create(
      attachment: fixture_file_upload('cov1.png')
    ).attachment_file_name.should == "cov1.png"
  end
end