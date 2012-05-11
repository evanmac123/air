class User::SegmentationData
  include Mongoid::Document

  field :ar_id
  field :demo_id
  field :characteristics
  field :updated_at

  index :ar_id, :unique => true
  index :demo_id
  index :characteristics
  index :updated_at

  def self.create_from_user(user)
    self.create!(user.values_for_segmentation)
  end

  def self.update_from_user(user)
    segmentation_record = self.where(:ar_id => user.id, :updated_at.lt => user.updated_at).update_all(user.values_for_segmentation)
  end

  def self.destroy_from_user(user)
    self.delete_all(:ar_id => user.id)
  end
end
