module ActsHelper
  def ranking_phrase(ranking, out_of)
    "#{ranking.ordinalize} out of #{out_of}"
  end
end
