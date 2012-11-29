class Admin::TagsController < AdminBaseController
  before_filter :find_tag, :only => [:show, :edit, :destroy, :update]

  def index
    @tags = Tag.order(:name)
  end
  
  def show
  end

  def edit
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new(params[:tag])

    if @tag.save
      redirect_to(admin_tags_path, :notice => 'Tag was successfully created.') 
    else
      render :action => "new" 
    end
  end

  def destroy
    @tag.destroy
    flash[:success] = "Tag deleted"
    redirect_to :back
  end

  def update
    @tag.attributes = params[:tag]

    if @tag.save
      flash[:success] = 'Tag updated'
    else
      flash[:failure] = "Error saving tag: " + @tag.errors.full_messages.to_sentence
    end

    redirect_to admin_tags_path
  end

  protected

  def find_tag
    @tag = Tag.find(params[:id])
  end
end
