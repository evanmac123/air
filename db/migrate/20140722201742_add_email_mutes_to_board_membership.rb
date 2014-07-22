class AddEmailMutesToBoardMembership < ActiveRecord::Migration
  def change
    add_column :board_memberships, :digest_muted, :boolean, default: false
    add_column :board_memberships, :followup_muted, :boolean, default: false
  end
end
