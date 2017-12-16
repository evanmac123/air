module Tile::TileAnswers
  extend ActiveSupport::Concern

  PRESET_CORRECT_ANSWER_INDEX = ["change_email", "custom_form", "invite_spouse"]

  included do
    serialize :multiple_choice_answers, Array

    before_validation :set_answers, if: :answers_populated?
  end

  #FIXME should not need to have separate answers field but some processing on the field needs to happen and the client side creates an answers field instead of multiple_choice_answers

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

   def normalized_answers
       answers.map(&:strip).select(&:present?)
   end

   def answers_changed?
     changes.keys.include? "answers"
   end

   def normalized_correct_answer_index
     if PRESET_CORRECT_ANSWER_INDEX.include?(question_subtype.downcase)
       0
     elsif  correct_answer_index
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
