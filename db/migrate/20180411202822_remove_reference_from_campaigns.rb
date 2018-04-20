class RemoveReferenceFromCampaigns < ActiveRecord::Migration
  def up
    add_reference :campaigns, :population_segment, index: true, foreign_key: true

    remove_reference :campaigns, :characteristic
  end

  def down
    remove_reference :campaigns, :population_segment
  end
end
