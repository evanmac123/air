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
        @tile.correct_answer_index = correct_answer_index_corrected_for_blanks
        @tile.multiple_choice_answers = answers
        @tile.points = @parameters[:points].to_i
      end
    end

    def build_rule
    end

    def build_rule_values
    end

    def main_objects
      [tile]
    end

    def remove_extraneous_rule_values
      true
    end

    def associate_rule_values_with_rule
    end

    def set_first_rule_value_as_primary
    end

    def create_trigger_if_needed
    end

    def remove_rule_value_error_on_rule
    end

    def update_rule
    end

    def update_rule_values
    end

    def inherent_errors
      []
    end

    def normalized_answers_from_tile
      tile && tile.multiple_choice_answers
    end

    def no_rule_values_given
      false
    end

    def correct_answer_index_corrected_for_blanks
      correct_answer_index = @parameters[:correct_answer_index].to_i
      blanks_preceding_correct_answer = answers_from_params[0, correct_answer_index].count(&:blank?)
      correct_answer_index - blanks_preceding_correct_answer
    end

    delegate :points, :to => :tile
  end
end
