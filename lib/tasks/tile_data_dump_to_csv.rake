require "csv"

task :tile_data_dump_to_csv, [:board_id] => [:environment] do |t, args|
  board = Demo.where(id: args[:board_id]).first

  if board
    puts "Downloading data to csv..."
    tiles = board.tiles.order("created_at DESC")

    CSV.open("#{board.id}_tile_data.csv","w", write_headers: true, headers: [
      "Question", "Answer", "Percentage", "Count"
      ]) do |csv|
      tiles.each do |tile|
        csv << [tile.question]
        tile.survey_chart.each do |answer|
          csv << [nil, answer["answer"], answer["percent"], answer["number"]]
        end
      end
    end
  else
    puts "Pass a valid board id to the task."
  end
end
