module TilesDigestConcern
  def sanitize_subject_line(subject)
    if subject
      subject.encode(Encoding::UTF_8, undef: :replace, invalid: :replace).gsub("\n", "").gsub("\r", "")
    end
  end
end
