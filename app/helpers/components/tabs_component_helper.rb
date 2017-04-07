module Components::TabsComponentHelper
  def tabs_component_active(current_node, active_node)
    if current_node == active_node
      "tabs-component-active"
    end
  end
end
