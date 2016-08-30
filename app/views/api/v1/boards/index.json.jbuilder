json.array!(@boards) do |board|
  json.(board, :id, :name)
end
