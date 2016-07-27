class User::SegmentationResults
  include Mongoid::Document

  field :owner_id
  field :explanation
  field :found_user_ids
  field :created_at

  field :segment_query_columns
  field :segment_query_operators
  field :segment_query_values

  index({owner_id: 1}, {:unique => true})

  before_save :set_created_at

  def self.create_or_update_from_search_results(
    owner,
    explanation,
    found_user_ids,
    segment_query_columns,
    segment_query_operators,
    segment_query_values
    )

    result_record = self.where(owner_id: owner.id).first
    result_record ||= self.new(owner_id: owner.id)
    result_record.explanation = explanation
    result_record.found_user_ids = found_user_ids

    # Saving these values allows us to fetch the users in this segment right before the job is actually run
    # (NOTE: No need to store the demo_id because that is set in the 'TargetedMessagesController.create' action
    #        and wanted to keep the intrusion onto existing - and working - code as minimal as possible.)
    result_record.segment_query_columns = segment_query_columns
    result_record.segment_query_operators = segment_query_operators
    result_record.segment_query_values    = segment_query_values

    result_record.save!
    result_record
  end

  def format_criteria
    explanation.map { |criteria|
      criteria.upcase
    }.to_sentence
  end

  private

  def set_created_at
    self.created_at = Time.now
  end
end
