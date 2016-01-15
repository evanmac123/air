class MultipleChoiceTile < Tile
  serialize :multiple_choice_answers, Array
  validate  :points_positive
  validate :at_least_one_answer_present
  belongs_to :demo

  before_validation :set_answers #FIXME should not need to have separate answers field but some processing on the field needs to happen and the client side creates an answers field instead of multiple_choice_answers

 attr_accessor :answers, :answers_normalizer

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

 private

 def set_answers
   self.correct_answer_index =    normalized_correct_answer_index
   self.multiple_choice_answers =  normalized_answers
 end

 def normalized_correct_answer_index
   answers_normalizer.normalized_correct_answer_index
 end

 def normalized_answers
   answers_normalizer.normalized_answers
 end

 def answers_normalizer
   @a ||= AnswersNormalizer.new( answers, correct_answer_index) 
 end


 class AnswersNormalizer
   def initialize(answers, index)
     @answers = (answers || [])
     @correct_answer_index = set_correct_answer_index(index)
   end

   def normalized_answers
     @answers.map(&:strip).select(&:present?).uniq
   end

   def normalized_correct_answer_index
     if @correct_answer_index
       @answers[0, @correct_answer_index + 1].reject(&:blank?).uniq.count - 1
     else
       -1
     end
   end

   protected

   def set_correct_answer_index(index)
     index.present? ? index.to_i : nil
   end

 end

end
