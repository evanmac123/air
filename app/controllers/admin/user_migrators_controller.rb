class Admin::UserMigratorsController < AdminBaseController


  def create
    migrator = UserBoardMigrator.new(params[:user_ids], params[:from], params[to]) 
    @summary  = migrator.execute(params[:commit])
    if @summary[:committed]
  end

  def edit
       
  end

end
