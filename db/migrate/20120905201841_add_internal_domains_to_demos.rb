class AddInternalDomainsToDemos < ActiveRecord::Migration
  def change
    add_column :demos, :internal_domains, :text
  end
end
