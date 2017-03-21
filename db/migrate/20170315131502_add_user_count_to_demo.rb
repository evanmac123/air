class AddUserCountToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :users_count, :integer
    data
  end

  def data
    execute <<-SQL.squish
       UPDATE demos
       SET users_count = (SELECT count(board_memberships.user_id)
       FROM board_memberships
       WHERE board_memberships.demo_id = demos.id)
    SQL
  end
end
