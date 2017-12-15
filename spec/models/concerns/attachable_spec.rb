require 'spec_helper'
require 'aws-sdk'
describe Attachable do

  let(:t){FactoryGirl.create(:multiple_choice_tile)}
  let(:t2){FactoryGirl.create(:multiple_choice_tile)}
  let(:s3){mock()}
  let(:bucket){ mock()}
  let(:buckets){ mock()}
  let(:objects){ mock()}
  let(:object){ mock()}
  let(:copy){ mock()}
  let(:pub_url){ mock()}

  before do
    AWS::S3.stubs(:new).returns(s3)
    s3.stubs(:buckets).returns(buckets)
    buckets.stubs(:[], APP_BUCKET).returns(bucket)
    bucket.stubs(:objects).returns(objects)
  end

  describe "#documents" do
    it "should return a document hash with two elements" do
      t = FactoryGirl.create(:multiple_choice_tile)
      t.stubs(:file_attachments).returns({"file1" =>"/file1.pdf", "file2" =>"/file2.pdf"})
      expect(t.documents).to eq({
        "file1" =>"https://#{APP_BUCKET}.s3.amazonaws.com/file1.pdf",
        "file2" =>"https://#{APP_BUCKET}.s3.amazonaws.com/file2.pdf"
      })
    end


    it "should return a document hash with 1 elements" do
      t = FactoryGirl.create(:multiple_choice_tile)
      t.stubs(:file_attachments).returns({"file1" =>"/file1.pdf"})
      expect(t.documents).to eq({
        "file1" =>"https://#{APP_BUCKET}.s3.amazonaws.com/file1.pdf"
      })
    end

    it "should return a document hash with 0 elements" do
      t = FactoryGirl.create(:multiple_choice_tile)
      t.stubs(:file_attachments).returns({})
      expect(t.documents).to eq({})
    end
  end

  describe "#delete_s3_attachments" do

    let(:t){FactoryGirl.create(:multiple_choice_tile)}
    context "deleting objecs" do
      let(:s3){mock()}
      let(:bucket){ mock()}
      let(:buckets){ mock()}
      let(:objects){ mock()}
      let(:object){ mock()}
      before do
        AWS::S3.stubs(:new).returns(s3)
        s3.stubs(:buckets).returns(buckets)
        buckets.stubs(:[], APP_BUCKET).returns(bucket)
        bucket.stubs(:objects).returns(objects)
      end
      it "should call s3 object delete for all elements" do
        t.stubs(:file_attachments).returns({"file1" =>"/file1.pdf", "file2" =>"/file2.pdf"})
        objects.expects(:[]).with("file1.pdf").returns(object)
        objects.expects(:[]).with("file2.pdf").returns(object)
        object.expects(:delete).twice
        t.delete_s3_attachments
      end

      it "should call s3 object delete for all elements" do
        t.stubs(:file_attachments).returns({"file1" =>"/file1.pdf"})
        objects.expects(:[]).with("file1.pdf").returns(object)
        object.expects(:delete).once
        t.delete_s3_attachments
      end

      it "should call s3 object delete for all elements" do
        t.stubs(:file_attachments).returns({})
        object.expects(:delete).never
        t.delete_s3_attachments
      end
    end

    describe "#copy_s3_object" do
      it "copies object to new key" do
        object.expects(:copy_to).returns(copy).once
        t.copy_attachment object, "file1.pdf",  t2
      end
    end

    describe "copy_s3_attachments_to" do
      it "copies all objects  to new tile" do
        t.stubs(:file_attachments).returns({"file1" =>"/file1.pdf", "file2" =>"/file2.pdf"})
        objects.expects(:[]).with("file1.pdf").returns(object)
        objects.expects(:[]).with("file2.pdf").returns(object)
        object.expects(:copy_to).returns(copy).twice
        t.copy_s3_attachments_to t2
      end
    end


    context "saving with attachments" do
      it "populates hash" do
        t = Tile.new
        t.attachments = ["DELETE", "https://s3.amazonaws.com/#{APP_BUCKET}/file1.pdf"]
        expect{t.valid?}.to change{t.file_attachments}.to({"file1_dot_pdf"=>"/airbo-development/file1.pdf"})
      end

      it "populates hash" do
        t = Tile.new
        t.file_attachments = {"file1_dot_pdf"=>"/airbo-development/file1.pdf"}
        t.stubs(:delete_s3_attachments)
        t.attachments = ["DELETE"]
        expect{t.save}.to change{t.file_attachments}.from({"file1_dot_pdf"=>"/airbo-development/file1.pdf"}).to({})
      end


      it "deletes elements not in attachments" do
        t = Tile.new
        t.file_attachments = {"file1.pdf"=>"/airbo-development/file1.pdf", "file2.pdf"=>"/airbo-development/file2.pdf"}
        t.attachments = ["DELETE", "https://s3.amazonaws.com/#{APP_BUCKET}/file1.pdf"]
        expect{t.save}.to change{t.file_attachments}.from({"file1.pdf"=>"/airbo-development/file1.pdf", "file2.pdf"=>"/airbo-development/file2.pdf"}).to({"file1_dot_pdf"=>"/airbo-development/file1.pdf"})
      end

      it "deletes elements not in attachments" do
        t = Tile.new
        t.file_attachments = {"file1.pdf"=>"/airbo-development/file1.pdf", "file2.pdf"=>"/airbo-development/file2.pdf", "file3.pdf"=>"/airbo-development/file3.pdf"}
        t.attachments = ["DELETE", "https://s3.amazonaws.com/#{APP_BUCKET}/file1.pdf", "https://s3.amazonaws.com/#{APP_BUCKET}/file3.pdf"]
        expect{t.save}.to change{t.file_attachments}.from({
          "file1.pdf"=>"/airbo-development/file1.pdf",
          "file2.pdf"=>"/airbo-development/file2.pdf",
          "file3.pdf"=>"/airbo-development/file3.pdf"
        }).to({"file1_dot_pdf"=>"/airbo-development/file1.pdf", "file3_dot_pdf"=>"/airbo-development/file3.pdf"})
      end

    end
  end

end
