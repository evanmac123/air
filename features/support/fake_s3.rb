require 'sinatra/base'

class FakeS3App < Sinatra::Base
  [
    "/avatars/:user_id/:style/:filename", # no bucket, hostname will take care of that below
    "/:bucket/tiles/:id/:filename",
    "/:bucket/tile_thumbnails/:id/:style/:filename"
  ].each do |path|
    put path do
      "OK"
    end

    delete path do
      "OK"
    end

    post path do
      "OK"
    end
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


ShamRack.at('hengage-avatars-development.s3.amazonaws.com', 443).rackup do
  run FakeS3App
end
