class Reports::BoardReport
  attr_reader :board, :from_date, :to_date

  def initialize(board_id:, from_date:, to_date:)
    @board = Demo.find(board_id)
    @from_date = from_date.to_date
    @to_date = to_date.to_date
  end
end
