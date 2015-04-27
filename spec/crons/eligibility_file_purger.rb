require 'spec_helper'

describe EligibilityFilePurger do
  describe "#purge!" do
    before do
      Timecop.freeze

      @mock_s3 = MockS3.install
      @old_object_keys = %w(old1.csv old2.csv)
      @new_object_keys = %w(new1.csv new2.csv)
      
      object_keys = @old_object_keys + @new_object_keys

      object_keys.each do |object_key| 
        @mock_s3.mount_string(object_key, object_key)
        @mock_s3.objects[object_key].stubs(:delete).returns(nil)
      end
   
      # We remember the old objects here because the fake S3 object collection
      # we interact with in these tests will not have a reference to these
      # objects after we delete them, as part of the fakery.
      @old_objects = []
      @old_object_keys.each_with_index do |object_key, i|
        old_modified_time = Time.now - EligibilityFilePurger::AGE_THRESHOLD - (2 * (i + 1)).minutes
        mock_object = @mock_s3.objects[object_key]
        mock_object.stubs(:last_modified).returns(old_modified_time)
        @old_objects << mock_object
      end
     
      @new_object_keys.each_with_index do |object_key, i|
        new_modified_time = Time.now - EligibilityFilePurger::AGE_THRESHOLD + (2 * (i + 1)).minutes
        @mock_s3.objects[object_key].stubs(:last_modified).returns(new_modified_time)
      end

      purger = EligibilityFilePurger.new('hengage-tmp')
      purger.purge!
    end

    after do
      Timecop.return
    end

    it "should delete all objects in the bucket older than the threshold" do
      @old_objects.each do |old_object|
        old_object.should have_received(:delete)
      end

      @old_object_keys.each do |old_object_key|
        @mock_s3.objects[old_object_key].should be_nil
      end
    end

    it "should not delete any objects in the bucker newer than the threshold" do
      @new_object_keys.each do |new_object_key|
        object = @mock_s3.objects[new_object_key]
        object.should have_received(:delete).never
      end
    end
  end
end
