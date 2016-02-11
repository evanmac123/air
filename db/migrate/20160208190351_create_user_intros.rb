class CreateUserIntros < ActiveRecord::Migration
  def change
    create_table :user_intros do |t|
      t.references :user
      t.boolean :explore_intro_seen, default: false

      t.timestamps
    end
    add_index :user_intros, :user_id
  end
end
