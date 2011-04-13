class AddDemoIdToAct < ActiveRecord::Migration
  def self.up
    add_column :acts, :demo_id, :integer

    Act.reset_column_information
    Act.all.each{|act| act.demo_id = act.user.try(:demo_id); act.save!}
  end

  def self.down
    remove_column :acts, :demo_id
  end
end
