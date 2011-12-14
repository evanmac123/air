class CreateOutgoingSms < ActiveRecord::Migration
  def self.up
    create_table :outgoing_sms do |t|
      t.string  :body
      t.string  :to
      t.belongs_to :in_response_to

      t.timestamps
    end
  end

  def self.down
    drop_table :outgoing_sms
  end
end
