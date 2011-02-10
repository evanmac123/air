class String
  def remove_mid_word_characters
    gsub(/'/, '')
  end

  def replace_non_words_with_spaces
    gsub(/[\W]/, ' ')
  end

  def remove_non_words
    gsub(/[\W]/, '')
  end

  def replace_spaces_with_hyphens
    gsub(/\ +/, '-')
  end

  def first_digit
    digit = split(/(\d)/)[1]
    if digit
      digit.to_i
    else
      0
    end
  end
end
