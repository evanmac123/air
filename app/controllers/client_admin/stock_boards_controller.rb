class ClientAdmin::StockBoardsController < ClientAdminBaseController
  def index
     sort_demos

  end

  def show
  end

 private

 def board_slugs
   @slugs ||= ENV['HOMEPAGE_BOARD_SLUGS'].split(",")
 end


 def sort_demos
   @demos = Demo.where(public_slug:board_slugs)
   @sorted_demos = board_slugs.map do|slug|
     @demos.where(public_slug: slug).first
   end.compact
 end


end
