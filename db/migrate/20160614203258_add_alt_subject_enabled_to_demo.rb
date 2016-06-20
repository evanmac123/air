class AddAltSubjectEnabledToDemo < ActiveRecord::Migration
  def change
    add_column :demos, :alt_subject_enabled, :boolean, default:false
  end
end
