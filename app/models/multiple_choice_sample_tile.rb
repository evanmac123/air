class MultipleChoiceSampleTile < MultipleChoiceTile
  include SampleTileBehavior

  def image_filename
    "sample_tile_multiple_choice_image.png"  
  end

  def thumbnail_filename
    "sample_tile_multiple_choice_thumbnail.png"  
  end

  def thumbnail_hover_filename
    "sample_tile_multiple_choice_hover_thumbnail.png"  
  end

  def headline
    "This is a tile."
  end

  def supporting_content 
    "Earn points by reading the content and answering the question below." 
  end

  def question 
    "To answer the question, simply click on the correct answer." 
  end

  def points
    5
  end

  def multiple_choice_answers
    ["I learned how tiles work."]
  end

  def correct_answer_index
    0
  end
end
