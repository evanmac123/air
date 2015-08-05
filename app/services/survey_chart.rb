class SurveyChart
  attr_reader :tile

  def initialize tile
    @tile = tile
  end

  # TODO: split to methods
  def build
    chart = []
    count = TileCompletion.where(tile_id: tile.id).count
    tile.multiple_choice_answers.each_with_index do |answer, i|
      chart[i] = {}
      chart[i]["answer"] = answer 
      chart[i]["number"] = TileCompletion.where(tile_id: tile.id, answer_index: i).count
      chart[i]["percent"] = if count > 0
        (chart[i]["number"].to_f * 100 / count).round(2).to_s + "%"
      else
        "0%"
      end
    end
    chart
  end
end
