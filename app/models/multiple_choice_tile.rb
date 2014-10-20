class MultipleChoiceTile < Tile
  serialize :multiple_choice_answers, Array
  validate  :points_positive
  validate :at_least_one_answer_present

  def form_builder_class
    TileBuilderForm
  end

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
end
