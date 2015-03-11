class TileBuilderForm::AnswersNormalizer
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