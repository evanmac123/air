require 'spec_helper'


describe ActsController do
  it 'should reject attempts to sign in with an invalid security token (as found in tile links in digest email)' do
    user = FactoryGirl.create :user
    get :index, tile_token: '123456789', user_id: user.id
    expect(response).to redirect_to sign_in_url
  end
end
