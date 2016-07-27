class User::SegmentationData
  include Mongoid::Document

  field :ar_id
  field :demo_ids
  field :characteristics
  field :updated_at

  index({ar_id: 1}, {unique: true})
  index({demo_ids: 1})
  index({characteristics: 1})
  index({updated_at: 1})

  def self.create_from_user(user)
    self.create!(user.values_for_segmentation)
  end

  def self.update_from_user(user, force = false)
    segmentation_record = self.where(:ar_id => user.id)
    unless force
      segmentation_record = segmentation_record.where(:updated_at.lt => user.updated_at.utc)
    end

    segmentation_record.update_all(user.values_for_segmentation)
  end

  def self.destroy_from_user(user)
    self.delete_all(conditions: {ar_id: user.id})
  end
end
