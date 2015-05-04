class TileBuilderForm::TileValidation
  attr_accessor :tile

  def initialize tile
    @tile = tile
  end

  def valid?
    tile.valid?(:client_admin) && !has_quiz_error?
  end

  def errors_values
    @errors_values ||= begin
      clean_error_messages
      if has_errors?
        tile.errors.values
      elsif has_quiz_error?
        [quiz_error_message]
      else
        []
      end
    end
  end

  protected

  def has_errors?
    tile.errors.values.count > 0
  end

  def clean_error_messages
    remove_thumbnail_error
  end

  def remove_thumbnail_error
    tile.errors.delete(:thumbnail)
  end

  def has_quiz_error?
    index = tile.correct_answer_index
    question_type = tile.question_type

    question_type == "Quiz" && (index.nil? || index < 0)
  end

  def quiz_error_message
    "For a quiz, you have to have to mark a correct answer." +
    " Click an answer in your tile to mark the correct answer"
  end
end