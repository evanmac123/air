module CustomResponder 
 
  DEF_FORM_PARTIAL_NAME = "form"

  def self.included(base)
    base.send :respond_to,  :html, :json
  end

  protected

  def index
  end

  def new_or_edit resource, form_partial=DEF_FORM_PARTIAL_NAME
    if request.xhr?
      render_form_only form_partial
    else
      respond_with(resource)
    end
  end


  def update_or_create resource, location=nil, msg=nil
    if resource.valid?
      resource.save
      if block_given?
        success(resource, location, msg, &Proc.new)
      else
        success(resource, location, msg)
      end
    else
      failure resource
    end
  end

  def delete_resource resource, location=nil
    resource.destroy
    msg = "#{resource.class.name.downcase} successfully deleted"
    if request.xhr?
      response.headers["X-Message"]=msg
      head :ok
    else
      flash[:notice]= msg
      respond_with resource, :location => location
    end
  end


#UTILITIES
#----------

  def success(resource, location, msg)
    resp =msg || default_success_msg
    if request.xhr?
      response.headers["X-Message"]= resp
      if block_given?
        yield
      else
        head :ok, :location => location  
      end
    else
      flash[:notice]= resp
      respond_with(resource, location: location)
    end
  end

  def failure resource, err=nil
    msg = err || resource.errors.full_messages.to_sentence
    if request.xhr?
      response.headers["X-Message"]= msg
      head :unprocessable_entity and return
    else
      flash[:error]= msg
      respond_with(resource)
    end
  end

  def render_form_only form_partial
    render :partial => form_partial, :layout => false and return
  end

  def default_success_msg
    "Request completed succesfully"
  end

  def default_error_msg
    "An error has occured. Unable to complete your request"
  end
end
