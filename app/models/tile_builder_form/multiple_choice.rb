module TileBuilderForm
  class MultipleChoice < TileBuilderForm::Base

    def default_answer_count
      2
    end

    def tile_class
      MultipleChoiceTile
    end

    def set_tile_attributes
      super
      if @parameters.present?
        @tile.correct_answer_index = correct_answer_index_for_blanks_and_duplicates
        @tile.multiple_choice_answers = normalized_answers_from_params
        @tile.points = @parameters[:points].to_i
      end
    end

    def normalized_answers_from_tile
      tile && tile.multiple_choice_answers
    end

    def main_objects
      [tile]
    end

    def correct_answer_index_for_blanks_and_duplicates
      correct_answer_index = correct_answer_index_from_params
      return -1 unless correct_answer_index
      answers_from_params[0, correct_answer_index + 1].reject(&:blank?).uniq.count - 1
    end

    def present_answer_marked_as_correct
      unless @parameters[:answers] && correct_answer_index_from_params.present? && @parameters[:answers][correct_answer_index_from_params].present?
        errors.add :base, 'must select a correct answer'
      end
    end

    def correct_answer_index_from_params
      return nil unless @parameters[:correct_answer_index].present?
      @parameters[:correct_answer_index].to_i    
    end

    def answer_prompt
      "Give the answers and mark the correct one. If survey, do not mark any."   
    end

    delegate :points, :to => :tile
  end
end
