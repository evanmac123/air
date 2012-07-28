require "spec_helper"

describe ActionMailer::Base do
  context "Invitation email has dynamic content" do
    before(:each) do
      @hopscotch = FactoryGirl.create(:demo, 
                                      invitation_blurb:    SecureRandom.hex(8), 
                                      invitation_bullet_1: SecureRandom.hex(8), 
                                      invitation_bullet_2: SecureRandom.hex(8), 
                                      invitation_bullet_3: SecureRandom.hex(8), 
                                      invitation_logo_filename: SecureRandom.hex(8) + ".png",
                                      invitation_screenshot_filename: SecureRandom.hex(8) + ".png")
      @finney = FactoryGirl.create(:user, demo: @hopscotch)
      @style = EmailStyling.new('somedomain.com')
    end

    it "builds the email with custom content" do
      @hopscotch.should be_valid 
      email = Mailer.invitation(@finney, nil, style: @style)
      
      [email.html_part.body, email.text_part.body].each do |body|
        body.should include(@hopscotch.invitation_blurb)
        body.should include(@hopscotch.invitation_bullet_1)
        body.should include(@hopscotch.invitation_bullet_2)
        body.should include(@hopscotch.invitation_bullet_3)
      end

      email.html_part.body.should include(@hopscotch.invitation_logo_filename)
      email.html_part.body.should include(@hopscotch.invitation_screenshot_filename)

     

    end


    it "html part has real <i>,<b> tags, not escaped. plain part has none", focus: true do
      @hopscotch.invitation_blurb = "Have a <b><i>GREAT</b></i> time!"
      @hopscotch.invitation_bullet_1 = "Live <b><i>NOW</i></b>!"
      email = Mailer.invitation(@finney, nil, style: @style)

      # Plain text part should remove any <i>, <b> tags we put in
      email.text_part.body.should include("Have a GREAT time!")
      email.text_part.body.should include("Live NOW!")
      email.text_part.body.should_not include("<b>")
      email.text_part.body.should_not include("<i>")


      # Neither part should not have any escaped left or right brackets
      %w(html_part text_part).each do |part|
        %w(&lt; &gt;).each do |escaped|
          email.send(part).body.should_not include(escaped)
        end
      end
      
      # Html part should have raw tags
      %w(<i> <b> </i> </b>).each do |tag|
        email.html_part.body.should include(tag)
      end
    end

    it "has the correct subject" do
      # with default subject
      email = Mailer.invitation(@finney, nil, style: @style)
      email.subject.should == InvitationEmail.subject(@hopscotch)
      # with default subject and a referrer
      dave = User.new(name: "Chicory Dave")
      email = Mailer.invitation(@finney, dave, style: @style)
      email.subject.should == InvitationEmail.subject_with_referrer(@hopscotch, dave)

      # with custom subjects
      @hopscotch.invitation_subject = "A <b>normal subject"
      @hopscotch.invitation_subject_with_referrer = "[referrer] says YES!"
      email = Mailer.invitation(@finney, nil, style: @style)
      email.subject.should == InvitationEmail.subject(@hopscotch)
      # with custom subject and referrer
      email = Mailer.invitation(@finney, dave, style: @style)
      email.subject.should == InvitationEmail.subject_with_referrer(@hopscotch, dave)
    end
  end
end
