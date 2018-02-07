require 'spec_helper'

describe IntercomPurger do
  def segment_id
    "fake_segment_id"
  end

  describe ".call" do
    it "initializes an IntercomPurger and calls perform" do
      fake_intercom_purger = mock('IntercomPurger')

      IntercomPurger.expects(:new).with(segment_id).returns(fake_intercom_purger)

      fake_intercom_purger.expects(:perform)

      IntercomPurger.call(segment_id: segment_id)
    end
  end

  describe "#perform" do
    before do
      @fake_user_ids = %w(abcdef 123456 foobar)
      @fake_users = @fake_user_ids.map do |fake_user_id|
        fake_user = mock("Intercom::User")
        fake_user
      end
    end

    it "should delete all users in the segment" do
      purger = IntercomPurger.new(segment_id)

      fake_intercom_user_service = mock('Intercom::Service::User')
      fake_intercom_user_collection = mock('Intercom::CollectionProxy')
      fake_intercom_user_collection.stubs(:each).multiple_yields(*@fake_users)

      purger.intercom_client.expects(:users).returns(fake_intercom_user_service).times(4)
      fake_intercom_user_service.expects(:find_all).with(segment_id: segment_id).returns(fake_intercom_user_collection)

      @fake_users.each do |fake_user|
        fake_intercom_user_service.expects(:delete).with(fake_user)
      end

      purger.perform
    end
  end
end
