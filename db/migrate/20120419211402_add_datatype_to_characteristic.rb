class AddDatatypeToCharacteristic < ActiveRecord::Migration
  def self.up
    add_column :characteristics, :datatype, :string
  end

  def self.down
    remove_column :characteristics, :datatype
  end
end
