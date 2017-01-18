class AddCounterCacheToOrganization < ActiveRecord::Migration
  def up
    add_column :organizations, :demos_count, :integer, null: false, default: 0
    Organization.find_each { |organization| Organization.reset_counters(organization.id, :demos) }
  end

  def down
    remove_column :organizations, :demos_count
  end
end
