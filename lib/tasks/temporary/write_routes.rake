desc 'Write out all defined routes in match order, with names. Target specific controller with CONTROLLER=x.'
task :write_routes => :environment do
  Rails.application.reload_routes!
  all_routes = Rails.application.routes.routes

  require 'rails/application/route_inspector'
  inspector = Rails::Application::RouteInspector.new

  CSV.open("routes.csv", "w") do |writer|
    inspector.format(all_routes).each do |r|
      writer << r.split(" ")
    end
  end
end
