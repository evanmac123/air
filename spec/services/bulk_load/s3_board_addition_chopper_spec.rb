require 'spec_helper'

describe BulkLoad::S3BoardAdditionChopper do
  EXPECTED_OBJECT_KEY = "uploads/arbitrary_csv.csv"

  def user_ids_linewise(users)
    users.map(&:id).join("\n") + "\n"
  end

  describe "#add_users_to_board" do
    it "adds users, with ID one per line, to the given board" do
      board = FactoryGirl.create(:demo)
      users = FactoryGirl.create_list(:user, 3)
      board.users.count.should == 0

      mock_s3 = MockS3.install
      mock_s3.mount_string(EXPECTED_OBJECT_KEY, user_ids_linewise(users))

      chopper = BulkLoad::S3BoardAdditionChopper.new("some_bucket", EXPECTED_OBJECT_KEY, board.id)

      chopper.add_users_to_board

      board.users.count.should == users.count
      users.each{|user| user.demo_ids.should include(board.id)}
    end
  end
end
