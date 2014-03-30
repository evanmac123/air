class CreateBoardMemberships < ActiveRecord::Migration
  def up
    create_table :board_memberships do |t|
      t.boolean :is_current, default: true
      t.boolean :is_client_admin, :boolean, default: false

      t.belongs_to :demo
      t.belongs_to :user
      t.timestamps
    end

    # It's bad form to use an ActiveRecord class in a migration like this,
    # but that's mainly because in a future version of the code said class
    # may disappear, and I don't see that happening with User anytime soon.
    BoardMembership.reset_column_information
    user_ids = User.pluck(:id)
    user_ids.each_with_index do |user_id, index|
      puts "MIGRATED #{index} USERS" if index % 1000 == 0
      user = User.find(user_id)
      BoardMembership.create!(demo_id: user[:demo_id], user_id: user.id, is_current: true, is_client_admin: user[:is_client_admin])
    end

    add_index :board_memberships, :demo_id
    add_index :board_memberships, :user_id
  end

  def down
    User.where(demo_id: nil).each_with_index do |user, index|
      puts "REVERTED #{index} USERS" if index % 1000 == 0
      user[:demo_id] = user.demo.id
      user.save!
    end
    drop_table :board_memberships
  end
end
