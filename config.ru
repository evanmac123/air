# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Health::Application


# Additional mime types
Rack::Mime::MIME_TYPES.merge!({
  ".eot" => "application/vnd.ms-fontobject",
  ".ttf" => "font/ttf",
  ".otf" => "font/otf",
  ".woff" => "application/font-woff"
})