class Admin::UnmatchedBoardsController < AdminBaseController


 def index
   @demos = Demo.unmatched
   @organizations = Organization.all
 end

 def update
   org = Organization.find(params[:organization])
   demos = Demo.where({id: params[:matched]})
   demos.update_all(organization_id: org.id)
   flash[:success]="Boards successfull linked to #{org.name}"
   redirect_to admin_unmatched_boards_path
 end

end
