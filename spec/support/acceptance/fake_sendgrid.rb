class FakeSendgridApp < Sinatra::Base
  get '/api/unsubscribes.add.xml' do
    'success'
  end
end

ShamRack.at('sendgrid.com', 443).rackup do
  run FakeSendgridApp
end
