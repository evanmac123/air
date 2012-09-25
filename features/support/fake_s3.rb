require 'sinatra/base'

class FakeS3App < Sinatra::Base
  put "/:bucket/avatars/:user_id/:filename" do
    "OK"
  end

  delete "/:bucket/avatars/:user_id/:filename" do
    "OK"
  end

  put "/:bucket/tiles/:id/:filename" do
    "OK"
  end

  delete "/:bucket/tiles/:id/:filename" do
    "OK"
  end
end

ShamRack.at('s3.amazonaws.com', 443).rackup do
  run FakeS3App
end

