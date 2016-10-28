class AddDelinquencyDateToContract < ActiveRecord::Migration
  def change
    add_column :contracts, :delinquency_date, :date
  end
end
