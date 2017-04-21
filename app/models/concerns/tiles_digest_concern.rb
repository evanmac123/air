module TilesDigestConcern
  def sanitize_subject_line(subject)
    if subject
      subject.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: '')
    end
  end
end
