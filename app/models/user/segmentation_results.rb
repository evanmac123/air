class User::SegmentationResults
  include Mongoid::Document

  field :owner_id
  field :explanation
  field :found_user_ids
  field :created_at

  index :owner_id, :unique => true

  before_save :set_created_at

  def self.create_or_update_from_search_results(owner, explanation, found_user_ids)
    result_record = self.where(:owner_id => owner.id).first
    result_record ||= self.new(:owner_id => owner.id)
    result_record.explanation = explanation
    result_record.found_user_ids = found_user_ids
    result_record.save!
    result_record
  end

  protected

  def set_created_at
    self.created_at = Time.now
  end
end
