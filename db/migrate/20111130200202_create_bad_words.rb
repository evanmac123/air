class CreateBadWords < ActiveRecord::Migration
  def self.up
    create_table :bad_words do |t|
      t.string :value, :null => false, :default => ''
      t.belongs_to :demo
      t.timestamps
    end

    add_index :bad_words, :value
    add_index :bad_words, :demo_id
  end

  def self.down
    drop_table :bad_words
  end
end
