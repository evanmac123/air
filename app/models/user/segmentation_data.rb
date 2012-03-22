class User::SegmentationData
  include Mongoid::Document

  field :ar_id
  field :characteristics

  index :ar_id, :unique => true
  index :characteristics

  def self.create_or_update_from_user(user)
    segmentation_record = self.where(:ar_id => user.id).first
    segmentation_record ||= self.new(:ar_id => user.id)
    segmentation_record.characteristics = user.characteristics.stringify_keys
    segmentation_record.save!
  end
end
