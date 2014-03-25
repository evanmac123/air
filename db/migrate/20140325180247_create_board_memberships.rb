class CreateBoardMemberships < ActiveRecord::Migration
  def up
    create_table :board_memberships do |t|
      t.boolean :is_current, default: true

      t.belongs_to :demo
      t.belongs_to :user
      t.timestamps
    end

    # It's bad form to use an ActiveRecord class in a migration like this,
    # but that's mainly because in a future version of the code said class
    # may disappear, and I don't see that happening with User anytime soon.
    BoardMembership.reset_column_information
    User.all.each do |user|
      BoardMembership.create!(demo_id: user.demo_id, user_id: user.id, is_current: true)
    end

    add_index :board_memberships, :demo_id
    add_index :board_memberships, :user_id
  end

  def down
    drop_table :board_memberships
  end
end
