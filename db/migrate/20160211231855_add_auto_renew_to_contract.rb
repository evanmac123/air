class AddAutoRenewToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :auto_renew, :boolean, default: true
  end
end
