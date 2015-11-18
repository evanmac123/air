module BodyClassHelper
  # TODO: move this into a gem/plugin
  def body_class
    qualified_controller_name = @html_body_controller_name || controller.controller_path.gsub('/','-')
    action_name = @html_body_action_name || controller.action_name

    "#{qualified_controller_name} #{qualified_controller_name}-#{action_name}"
  end

  def body_pages_class
    qualified_controller_name = @html_body_controller_name || controller.controller_path.gsub('/','-')
    action_name = @html_body_action_name || params[:id] || params[:action]

    "#{qualified_controller_name} #{qualified_controller_name}-#{action_name}"
  end
end
