
class Admin::BulkUserDeletionsController < AdminBaseController

   def show
     @demo = Demo.find(params[:demo_id])
     @users = BoardMembership.select("is_client_admin, count(id)").where(demo_id: params[:demo_id]).group(:is_client_admin).all
   end

   def create
     BulkUserDeletionJob.new(params).perform
     @demo = Demo.find(params[:demo_id])
     flash[:success]="You bulk Deletion job for users in #{@demo.name} has been triggered"
     redirect_to admin_demo_path(params[:demo_id])
   end

end
