module ActsHelper
  def ranking_phrase(ranking, out_of)
    ordinal_particle = ranking.ordinalize[-2,2]
    "<span class=\"rank-number\">#{ranking}</span><span class=\"ordinal-particle\">#{ordinal_particle}</span><br/> out of #{out_of}"
  end
end
