require 'sinatra/base'

class FakeS3App < Sinatra::Base
  put "/:bucket/avatars/:user_id/:filename" do
    "OK"
  end

  delete "/:bucket/avatars/:user_id/:filename" do
    "OK"
  end
end

ShamRack.at('s3.amazonaws.com', 80).rackup do
  run FakeS3App
end

