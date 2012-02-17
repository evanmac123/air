class BadMessageBodyStringToText < ActiveRecord::Migration
  def self.up
    change_column :bad_messages, :body, :text
  end

  def self.down
    change_column :bad_messages, :body, :string
  end
end
