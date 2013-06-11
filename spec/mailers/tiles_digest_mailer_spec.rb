require "spec_helper"
include TileHelpers

describe 'Tiles digest email_spec' do
  let(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday }

  before(:each) do
    create_tile demo: demo
    @email = TilesDigestMailer.notify(demo)
  end

  it 'should work' do
    @email.should be_delivered_to('joe@blow.com')
    @email.should be_delivered_from('donotreply@hengage.com')
    @email.should have_subject('Newly-added H.Engage Tiles')
    @email.should have_body_text('Check out our')
    @email.should have_body_text('new tiles')
  end
end

  describe 'Tiles digest email' do
  let(:demo) { FactoryGirl.create :demo, tile_digest_email_sent_at: Date.yesterday }

  # todo Doesn't work if no text version of the email (html_part is nil)
  before(:each) do
    create_tile demo: demo
    TilesDigestMailer.notify(demo).deliver
    #p "******* #{ActionMailer::Base.deliveries.first.html_part.body.inspect}"
  end

  # todo use email_spec helpers
  it 'has the right content in the right places' do
    TilesDigestMailer.should have_sent_email.from('donotreply@hengage.com')
                                            .to('joe@blow.com')
                                            .with_subject('Newly-added H.Engage Tiles')
                                            #.with_body('Check out')
                                            #.with_part('text/html', /Our mailing address is:/)
  end
end
