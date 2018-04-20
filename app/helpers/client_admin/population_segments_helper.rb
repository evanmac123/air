module ClientAdmin::PopulationSegmentsHelper
  def population_segments_json
    current_board.population_segments.map do |segment|
      {
        id: segment.id,
        name: segment.name,
        user_count: segment.user_count
      }
    end.to_json
  end
end
