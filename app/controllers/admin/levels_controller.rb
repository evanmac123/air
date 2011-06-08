class Admin::LevelsController < ApplicationController
  before_filter :find_demo, :only => [:new, :create]
  before_filter :find_level, :only => [:edit, :update, :destroy]

  def new
    @level = @demo.levels.new
    render :template => 'admin/levels/form'
  end

  def create
    @level = @demo.levels.build(params[:level])

    if @level.save
      flash[:success] = "Level created"
    else
      flash[:failure] = "Couldn't create level: #{@level.errors.full_messages}"
    end

    redirect_to admin_demo_path(@demo)
  end

  def destroy
    @level.destroy
    flash[:success] = "Level deleted"
    redirect_to admin_demo_path(@level.demo)
  end

  def edit
    render :template => 'admin/levels/form'
  end

  def update
    @level.attributes = params[:level]

    if @level.save
      flash[:success] = "Level updated"
    else
      flash[:failure] = "Couldn't update level: #{@level.errors.full_messages}"
    end

    redirect_to admin_demo_path(@level.demo)
  end

  protected

  def find_demo
    @demo = Demo.find(params[:demo_id])
  end

  def find_level
    @level = Level.find(params[:id])
  end
end
