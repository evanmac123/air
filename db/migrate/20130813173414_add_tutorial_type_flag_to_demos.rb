class AddTutorialTypeFlagToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :tutorial_type, :string, default: 'multiple_choice'
  end
end
