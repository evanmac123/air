class AddAcceptedInvitationAtToBoardMemberships < ActiveRecord::Migration
  def change
    add_column :board_memberships, :joined_board_at, :datetime
    remove_column :board_memberships, :displayed_tile_post_guide
    remove_column :board_memberships, :displayed_tile_success_guide
  end
end
