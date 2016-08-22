class MultipleChoiceTile < Tile
  serialize :multiple_choice_answers, Array
  validate  :points_positive
  validate :at_least_one_answer_present
  belongs_to :demo

  #FIXME should not need to have separate answers field but some processing on the field needs to happen and the client side creates an answers field instead of multiple_choice_answers


  before_validation :set_answers, :if => :answers_populated?

  def points_positive
    unless points.present? && points > 0
      errors.add :base, "points can't be blank"
    end
  end

  def at_least_one_answer_present
    unless multiple_choice_answers && multiple_choice_answers.any?(&:present?)
      errors.add :base, 'must have at least one answer'
    end
  end

  def answers
    @answers || []
  end

  def answers= values
    @answers= values
  end

 private

 def set_answers
   self.correct_answer_index =  normalized_correct_answer_index
   self.multiple_choice_answers =  normalized_answers
 end

 def normalized_correct_answer_index
   normalized_correct_answer_index
 end

 def normalized_answers
     answers.map(&:strip).select(&:present?).uniq
 end

 def answers_changed?
   changes.keys.include? "answers"
 end

 def normalized_correct_answer_index
   if correct_answer_index
     answers[0, correct_answer_index + 1].reject(&:blank?).uniq.count - 1
   else
     -1
   end
 end

 def set_correct_answer_index(index)
   index.present? ? index.to_i : nil
 end

def answers_populated?
  !answers.empty?
end

end
