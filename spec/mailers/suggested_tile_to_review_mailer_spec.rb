require "spec_helper"

describe SuggestedTileToReviewMailer do
  let(:demo) {FactoryGirl.create :demo}

  describe "#notify_one" do
    before do
      @client_admin = FactoryGirl.create :client_admin, email: "ca@airbo.com"
      @tile_sender =  FactoryGirl.create :user, email: "user@airbo.com", name: "Tile Sender"
    end

    let(:mail) do 
      SuggestedTileToReviewMailer.notify_one  @client_admin.id, demo.id, 
                                              @tile_sender.name, @tile_sender.email
    end

    it 'renders the subject' do
      expect(mail.subject).to eql("New Tile Suggested To Review")
    end

    it 'renders the receiver email' do
      expect(mail.to).to eql([@client_admin.email])
    end

    it 'renders the sender email' do
      expect(mail.from).to eql(["suggestion_box@airbo.com"])
    end

    it 'has correct CTA text' do
      expect(mail.body.encoded).to match("#{@tile_sender.name} #{@tile_sender.email} has submitted a Tile for your review.")
    end

    it 'does not mention not having to log in ' do
      expect(mail.body.encoded).not_to match("You won't have to log in.")
    end
  end
end
