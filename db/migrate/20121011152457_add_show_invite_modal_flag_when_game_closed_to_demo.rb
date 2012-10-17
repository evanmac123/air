class AddShowInviteModalFlagWhenGameClosedToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :show_invite_modal_when_game_closed, :boolean, :default => false
  end
end
