require "spec_helper"

describe SuggestedTileReviewMailer do
  let!(:demo) {FactoryBot.create :demo, email: "demo@gmail.com"}

  describe "#notify_one" do
    before do
      @client_admin = FactoryBot.create :client_admin, email: "ca@airbo.com"
      @tile_sender =  FactoryBot.create :user, email: "user@airbo.com", name: "Tile Sender"
    end

    let(:mail) do
      SuggestedTileReviewMailer.notify_one(@client_admin.id, demo.id, @tile_sender.name, @tile_sender.email)
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("New Tile Submitted Needs Review")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([@client_admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql([demo.email])
    end

    it 'has correct link' do
      expect(mail.body.encoded).to match(submitted_tile_notifications_url)
    end

    it 'does not mention not having to log in ' do
      expect(mail.body.encoded).not_to match("You won't have to log in.")
    end
  end
end
