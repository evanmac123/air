class Admin::UnmatchedBoardsController < AdminBaseController


 def index
   @demos = Demo.unmatched
   @organizations = Organization.all
 end

 def update

 end

end
