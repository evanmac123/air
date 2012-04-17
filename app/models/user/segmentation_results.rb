class User::SegmentationResults
  include Mongoid::Document

  field :owner_id
  field :explanation
  field :found_user_ids

  index :admin_ar_id, :unique => true

  def self.create_or_update_from_search_results(owner, explanation, found_user_ids)
    result_record = self.where(:owner_id => owner.id).first
    result_record ||= self.new(:owner_id => owner.id)
    result_record.explanation = explanation
    result_record.found_user_ids = found_user_ids
    result_record.save!
    result_record
  end
end
