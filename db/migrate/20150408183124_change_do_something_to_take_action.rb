class ChangeDoSomethingToTakeAction < ActiveRecord::Migration
  def up
    execute "UPDATE tiles SET question_subtype = 'take_action' WHERE question_subtype = 'do_something'"
  end

  def down
    execute "UPDATE tiles SET question_subtype = 'do_something' WHERE question_subtype = 'take_action'"
  end
end
