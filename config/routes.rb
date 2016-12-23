class ActionDispatch::Routing::Mapper
  def draw(routes_name)
    instance_eval(File.read(Rails.root.join("config/routes/#{routes_name}.rb")))
  end
end

Health::Application.routes.draw do
  draw :application
  draw :client_admin
  draw :explore
  draw :admin
  draw :api
end
