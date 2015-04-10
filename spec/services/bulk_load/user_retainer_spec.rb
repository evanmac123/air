require 'spec_helper'

describe BulkLoad::UserRetainer do
  let(:redis) {Redis.new}
  let(:object_key) {"some_file.csv"}

  before do
    Redis.new.flushdb
  end

  describe "#retain_user" do
    it "should easily let you remove a user from the set to be removed" do
      board = FactoryGirl.create(:demo)
      users = FactoryGirl.create_list(:user, 2, demo: board)

      retainer = BulkLoad::UserRetainer.new(object_key)
      rig_user_ids_for_bulk_removal(retainer, users.map(&:id))
      expect_user_ids_in_queue(retainer, users.map(&:id))

      user_to_keep = users.first
      user_to_remove = users.last
      retainer.retain_user(user_to_keep.id)

      expect_user_ids_in_queue(retainer, [user_to_remove.id])
    end
  end
end
