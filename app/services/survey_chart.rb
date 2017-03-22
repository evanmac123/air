class SurveyChart
  attr_reader :tile

  def initialize tile
    @tile = tile
  end

  def build
    agg = tile.tile_completions.group(:answer_index).count
    count = agg.values.sum

    tile.multiple_choice_answers.inject([]) do |chart, answer|
      answer_hsh = {}
      answer_hsh["answer"] = answer
      answer_hsh["number"] = agg[chart.length].to_i

      if count > 0
        answer_hsh["percent"] = (answer_hsh["number"].to_f * 100 / count).round(2)
      else
        answer_hsh["percent"] = 0
      end

      chart << answer_hsh
    end
  end
end
