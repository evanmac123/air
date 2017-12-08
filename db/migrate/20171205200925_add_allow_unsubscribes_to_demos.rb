class AddAllowUnsubscribesToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :allow_unsubscribes, :boolean, default: false
  end
end
