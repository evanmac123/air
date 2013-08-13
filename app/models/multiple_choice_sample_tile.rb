class MultipleChoiceSampleTile < MultipleChoiceTile
  include SampleTileBehavior

  def supporting_content 
    "Supporting Content" 
  end

  def question 
    "What is two plus two?" 
  end

  def points
    0
  end

  def multiple_choice_answers
    %w(2 3 4 5)
  end

  def correct_answer_index
    2
  end
end
