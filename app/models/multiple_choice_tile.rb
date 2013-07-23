class MultipleChoiceTile < Tile
  serialize :multiple_choice_answers, Array

  def form_builder_class
    TileBuilderForm::MultipleChoice
  end
end
