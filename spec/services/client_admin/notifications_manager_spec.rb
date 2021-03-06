require 'spec_helper'

describe ClientAdmin::NotificationsManager do

  describe ".set_tile_email_report_notifications" do
    let(:board) { FactoryBot.create(:demo) }
    let(:client_admin_1) { FactoryBot.create(:client_admin) }
    let(:client_admin_2) { FactoryBot.create(:client_admin) }

    before do
      board.board_memberships.create(user_id: client_admin_1.id, is_client_admin: true)
      board.board_memberships.create(user_id: client_admin_2.id, is_client_admin: true)
    end

    it "asks each client_admin to set_tile_email_report_notification" do
      User.any_instance.expects(:set_tile_email_report_notification).twice.with(board_id: board.id)

      ClientAdmin::NotificationsManager.set_tile_email_report_notifications(board: board)
    end
  end
end
