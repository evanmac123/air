class AddCoverMessageToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :cover_message, :string, default: "", null: false
  end
end
