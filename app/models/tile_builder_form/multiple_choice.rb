module TileBuilderForm
  class MultipleChoice < TileBuilderForm::Base
    validate :present_answer_marked_as_correct

    def default_answer_count
      2
    end

    def tile_class
      MultipleChoiceTile
    end

    def set_tile_attributes
      super
      if @parameters.present?
        @tile.correct_answer_index = correct_answer_index_corrected_for_blanks
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

    def correct_answer_index_corrected_for_blanks
      correct_answer_index = correct_answer_index_from_params
      blanks_preceding_correct_answer = answers_from_params[0, correct_answer_index].count(&:blank?)
      correct_answer_index - blanks_preceding_correct_answer
    end

    def present_answer_marked_as_correct
      unless @parameters[:answers] && @parameters[:answers][correct_answer_index_from_params].present?
        errors.add :base, 'must select a correct answer'
      end
    end

    def correct_answer_index_from_params
      @parameters[:correct_answer_index].to_i    
    end

    delegate :points, :to => :tile
  end
end
