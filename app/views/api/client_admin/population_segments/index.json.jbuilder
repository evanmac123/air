json.array! @population_segments do |segment|
  json.id segment.id
  json.name segment.name
  json.user_count segment.user_count
end
