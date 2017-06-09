require 'spec_helper'

describe ExploreConcern do

  before do
    class FakeController < ApplicationController
      include ExploreConcern
    end
  end

  after { Object.send :remove_const, :FakeController }

  let(:subject) { FakeController.new }

  describe '#explore_email_clicked_ping' do
    it "sends a ping with the correct properties" do
      user = FactoryGirl.create(:client_admin)
      email_type = "explore_digest"
      email_version = "1,1,17"

      subject.stubs(:ping)

      subject.explore_email_clicked_ping({
        user: user,
        email_type: email_type,
        email_version: email_version
      })

      properties = {
        email_type: email_type,
        email_version: email_version,
      }

      expect(subject).to have_received(:ping).with("Email clicked", properties, user)
    end
  end
end
