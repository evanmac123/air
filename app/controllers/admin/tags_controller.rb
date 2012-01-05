class FagsController < ApplicationController
  # GET /fags
  # GET /fags.xml
  def index
    @fags = Fag.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @fags }
    end
  end

  # GET /fags/1
  # GET /fags/1.xml
  def show
    @fag = Fag.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @fag }
    end
  end

  # GET /fags/new
  # GET /fags/new.xml
  def new
    @fag = Fag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @fag }
    end
  end

  # GET /fags/1/edit
  def edit
    @fag = Fag.find(params[:id])
  end

  # POST /fags
  # POST /fags.xml
  def create
    @fag = Fag.new(params[:fag])

    respond_to do |format|
      if @fag.save
        format.html { redirect_to(@fag, :notice => 'Fag was successfully created.') }
        format.xml  { render :xml => @fag, :status => :created, :location => @fag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @fag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /fags/1
  # PUT /fags/1.xml
  def update
    @fag = Fag.find(params[:id])

    respond_to do |format|
      if @fag.update_attributes(params[:fag])
        format.html { redirect_to(@fag, :notice => 'Fag was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @fag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /fags/1
  # DELETE /fags/1.xml
  def destroy
    @fag = Fag.find(params[:id])
    @fag.destroy

    respond_to do |format|
      format.html { redirect_to(fags_url) }
      format.xml  { head :ok }
    end
  end
end
