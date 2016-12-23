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

  constraints Clearance::Constraints::SignedOut.new do
    root to: 'pages#show'
  end

  constraints Clearance::Constraints::SignedIn.new { |user| user.is_site_admin || user.is_client_admin } do
    root to: 'explore#show'
  end

  constraints Clearance::Constraints::SignedIn.new do
    root to: 'acts#index'
  end
end
