require 'spec_helper'

describe IntercomPurger do
  def segment_id
    "fake_segment_id"
  end

  describe "#purge!" do
    before do
      @fake_user_ids = %w(abcdef 123456 foobar)
      @fake_users = @fake_user_ids.map do |fake_user_id| 
        fake_user = mock("Intercom::User")
        fake_user.stubs(:id).returns(fake_user_id)
        fake_user.stubs(:delete)
        Intercom::User.stubs(:find).with(id: fake_user_id).returns(fake_user)
        fake_user
      end

      fake_intercom_user_collection = mock('Intercom::CollectionProxy')
      fake_intercom_user_collection.stubs(:each).multiple_yields(*@fake_users)

      Intercom::User.stubs(:find_all).with(segment_id: segment_id).returns(fake_intercom_user_collection)
    end

    it "should schedule deletion of all users in the segment" do
      crank_dj_clear

      purger = IntercomPurger.new(segment_id)
      purger.purge!

      Delayed::Job.all.should have(3).queued_jobs

      crank_dj_clear
      @fake_users.each do |fake_user|
        fake_user.should have_received(:delete)
      end
    end
  end
end
