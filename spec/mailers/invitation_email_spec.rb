require "spec_helper"

describe ActionMailer::Base do
  context "Invitation email has dynamic content" do
    before(:each) do
      @hopscotch = FactoryGirl.create(:demo, 
                                      invitation_blurb:     SecureRandom.hex(8), 
                                      invitation_bullet_1a: SecureRandom.hex(8), 
                                      invitation_bullet_1b: SecureRandom.hex(8), 
                                      invitation_bullet_2a: SecureRandom.hex(8), 
                                      invitation_bullet_2b: SecureRandom.hex(8), 
                                      invitation_bullet_3a: SecureRandom.hex(8), 
                                      invitation_bullet_3b: SecureRandom.hex(8), 
                                      invitation_logo_filename: SecureRandom.hex(8) + ".png",
                                      invitation_screenshot_filename: SecureRandom.hex(8) + ".png")
      @finney = FactoryGirl.create(:user, demo: @hopscotch)
    end

    it "builds the email with custom content" do
      @hopscotch.should be_valid 
      style = EmailStyling.new('somedomain.com')
      email = Mailer.invitation(@finney, nil, style: style)
      InvitationEmail.bullet_1a(@finney)
      [email.html_part.body, email.text_part.body].each do |body|
        body.should include(@hopscotch.invitation_blurb)
        body.should include(@hopscotch.invitation_bullet_1a)
        body.should include(@hopscotch.invitation_bullet_2a)
        body.should include(@hopscotch.invitation_bullet_3a)
        
        body.should include(@hopscotch.invitation_bullet_1b)
        body.should include(@hopscotch.invitation_bullet_2b)
        body.should include(@hopscotch.invitation_bullet_3b)

      end

      email.html_part.body.should include(@hopscotch.invitation_logo_filename)
      email.html_part.body.should include(@hopscotch.invitation_screenshot_filename)


    end
  end
end
