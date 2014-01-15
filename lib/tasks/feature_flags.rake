namespace :feature do
  desc "Set the public board flag for a board"
  task :public_board, [:board_id] => :environment do |task, args|
    board = Demo.find(args[:board_id])
    $rollout.activate_user(:public_board, board)
  end
end
