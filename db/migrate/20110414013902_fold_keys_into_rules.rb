class FoldKeysIntoRules < ActiveRecord::Migration
  def self.up
    if const_defined?("Rule")
      Rule.all.each do |rule|
        full_name = if (key_id = rule['key_id'])
                        k = Key.find(key_id)
                        "#{k.name} #{rule.value}"
                    else
                      rule.value
                    end

        rule.update_attribute(:value, full_name)
      end
    end

    remove_column :rules, :key_id
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
