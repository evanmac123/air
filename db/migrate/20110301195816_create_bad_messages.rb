class CreateBadMessages < ActiveRecord::Migration
  def self.up
    create_table :bad_messages do |t|
      t.string   :phone_number
      t.string   :body
      t.datetime :received_at

      t.belongs_to :user

      t.timestamps
    end
  end

  def self.down
    drop_table :bad_messages
  end
end
