class Admin::UserMigratorsController < AdminBaseController
  def index
    @demos = Demo.all.order("name asc").all
  end

  def new
    @demos = Demo.all.order("name asc").all
  end

  def create
    ids = params[:user_ids].gsub(/[\r\n]/, "").split(",").map(&:to_i)
    migrator = UserBoardMigrator.new(ids, params[:from], params[:to])

    @summary = migrator.execute(params[:perform])

    if @summary.perform.nil?
      render :edit
    else
      flash[:success]="User points successfully migrated";
     render :show
    end
  end

  def show

  end

end
