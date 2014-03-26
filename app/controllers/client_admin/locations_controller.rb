class ClientAdmin::LocationsController < ClientAdminBaseController
  def create
    respond_to do |format|
      format.js do
        location = create_new_location(params[:location_name].strip)
        load_locations
        render partial: 'client_admin/users/location_select', locals: {locations: @locations, selected_location_id: location.try(:id)}
      end
    end
  end

  protected

  def create_new_location(name)
    demo_id = current_user.demo.id
    location = Location.new(demo_id: demo_id, name: name)
    location.save ? location : nil
  end
end
