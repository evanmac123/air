class Admin::UserTransfersController < AdminBaseController
  
  def update
    new_demo_name = params[:user][:demo_name]
    new_demo = Demo.find_by_name(new_demo_name)
    if new_demo
      current_user.demo_id = new_demo.id
      if current_user.save
        add_success "You are now in #{new_demo.name}"
      end
    else
      add_failure "Unable to find game named #{new_demo.name}"
    end
    redirect_to :back
  end
end
