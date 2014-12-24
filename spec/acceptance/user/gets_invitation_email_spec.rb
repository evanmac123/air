require 'acceptance/acceptance_helper'

include EmailHelper

feature 'User gets invitation email' do
  def expect_email_content(expected_content)
    crank_dj_clear
    open_email(@user.email)
    current_email.to_s.gsub(/\r\n/, "\n").should include(expected_content)
  end

  def expect_no_email_content(unexpected_content)
    crank_dj_clear
    open_email(@user.email)
    current_email.to_s.gsub(/\r\n/, "\n").should_not include(unexpected_content)
  end

  def expect_subject(expected_subject)
    crank_dj_clear
    open_email(@user.email)
    current_email.subject.should == expected_subject
  end

  before(:each) do
    @demo = FactoryGirl.create(:demo, :with_email)
    @user = FactoryGirl.create(:user, demo: @demo, name: "Dude Duderson")
    @referrer = FactoryGirl.create(:user, demo: @demo, name: "Andy McReferrer")
  end

  context "from a demo that has a reply email name set" do
    before(:each) do
      @demo.update_attributes(custom_reply_email_name: "The Team At BigCo")
      @user.invite
    end

    it "should use that name in the From: field" do
      expect_email_content("From: The Team At BigCo <#{@demo.email}>")
    end
  end

  context "from a demo that has no reply email name set" do
    before(:each) do
      @demo.custom_reply_email_name.should be_blank
      @user.invite
    end

    it "should use the name of the game in the From: field" do
      expect_email_content("From: #{@demo.name} <#{@demo.email}>")
    end
  end

  context "from a demo that has custom email HTML" do
    before(:each) do
      @expected_html = <<-END_HTML
<p>Welcome to H.Engage!</p>
<p>It's awesome. You'll love it.</p>
      END_HTML

      @custom_invitation_email = FactoryGirl.create(:custom_invitation_email, demo: @demo, custom_html_text: @expected_html)
    end

    it "should use that HTML" do
      @user.invite
      expect_email_content(@expected_html)
    end

    custom_html_with_blocks = <<-END_HTML
<p>Welcome to H.Engage!</p>[referrer_block]<p>You have a referrer.<p>[/referrer_block][no_referrer_block]<p>You have no referrer.</p>[/no_referrer_block][referrer_block]<p>That person must think you're awesome.</p>[/referrer_block][no_referrer_block]<p>Nobody loves you.</p>[/no_referrer_block][referrer_block]<p>Your friend [referrer] must love you very much.</p>[/referrer_block]<p>Either way, welcome.</p>
    END_HTML

    context "when there's a referrer" do
      it "should render all referrer blocks, with interpolation, and no noreferrer blocks" do
        @custom_invitation_email.custom_html_text = custom_html_with_blocks
        @custom_invitation_email.save!

        @user.invite(@referrer)

        expected_html = <<-END_EXPECTED_HTML
<p>Welcome to H.Engage!</p><p>You have a referrer.<p><p>That person must think you're awesome.</p><p>Your friend #{@referrer.name} must love you very much.</p><p>Either way, welcome.</p>
        END_EXPECTED_HTML

        expect_email_content expected_html
      end
    end

    context "when there's no referrer" do
      it "should render all noreferrer blocks, and no noreferrer blocks" do
        @custom_invitation_email.custom_html_text = custom_html_with_blocks
        @custom_invitation_email.save!

        @user.invite

        expected_html = <<-END_EXPECTED_HTML
<p>Welcome to H.Engage!</p><p>You have no referrer.</p><p>Nobody loves you.</p><p>Either way, welcome.</p>
        END_EXPECTED_HTML

        expect_email_content expected_html
      end
    end
  end

  context "from a demo that has no custom HTML" do
    it "should use the default HTML" do
      @user.invite
      expect_email_content "Your invitation to the #{@demo.name}"
      expect_email_content "Our social space to feature what you should know and do."
    end
  end

  context "from a demo with custom plain text" do
    before(:each) do
      @expected_text = <<-END_TEXT
Some would say H.Engage is the greatest thing since sliced bread.
We say it's better.
      END_TEXT

      @custom_invitation_email = FactoryGirl.create(:custom_invitation_email, demo: @demo, custom_plain_text: @expected_text)
    end

    it "should use that text" do
      @user.invite
      expect_email_content(@expected_text)
    end
    
    custom_plain_text_with_blocks = <<-END_PLAINTEXT
Welcome to H.Engage!
[referrer_block]You have a referrer.[/referrer_block]
[no_referrer_block]You have no referrer.[/no_referrer_block]
[referrer_block]That person must think you're awesome.[/referrer_block]
[no_referrer_block]Nobody loves you.[/no_referrer_block]
[referrer_block]Your friend [referrer] must love you very much.[/referrer_block]
Either way, welcome.
    END_PLAINTEXT


    context "when there's a referrer" do
      it "should render all referrer blocks, with interpolation, and no no-referrer blocks" do
        @custom_invitation_email.custom_plain_text = custom_plain_text_with_blocks
        @custom_invitation_email.save!

        @user.invite(@referrer)

        expected_text = <<-END_EXPECTED_TEXT
Welcome to H.Engage!
You have a referrer.
That person must think you're awesome.
Your friend #{@referrer.name} must love you very much.
Either way, welcome.
        END_EXPECTED_TEXT

        expect_email_content(expected_text)
      end
    end

    context "when there's no referrer" do
      it "should render all noreferrer blocks, and no referrer blocks" do
        @custom_invitation_email.custom_plain_text = custom_plain_text_with_blocks
        @custom_invitation_email.save!

        @user.invite

        expected_text = <<-END_EXPECTED_TEXT
Welcome to H.Engage!
You have no referrer.
Nobody loves you.
Either way, welcome.
        END_EXPECTED_TEXT

        expect_email_content(expected_text)
      end
    end
  end

  context "from a demo with no custom plain text" do
    it "should use the default text" do
      @user.invite
      expect_email_content "Your invitation to join the #{@demo.name}"
      expect_email_content "Our social space to feature what you should know and do."
    end
  end

  context "and there's a referrer" do
    context "and there's a custom subject-with-referrer" do
      before(:each) do
        email_subject = "[referrer] wants you to buy in to our deal, [user]"
        FactoryGirl.create(:custom_invitation_email, demo: @demo, custom_subject_with_referrer: email_subject)
      end

      it "should use that" do
        @user.invite(@referrer)
        expect_subject "#{@referrer.name} wants you to buy in to our deal, #{@user.name}"
      end
    end

    context "but there's no custom subject-with-referrer" do
      it "should use the default" do
        @user.invite(@referrer)
        expect_subject "#{@referrer.name} invited you to join the #{@demo.name}"
      end
    end
  end

  context "with no referrer" do
    context "and there's a custom subject" do
      it "should use that" do
        FactoryGirl.create(:custom_invitation_email, demo_id: @demo.id, custom_subject: "KNEEL BEFORE ZOD")
        @user.invite
        expect_subject "KNEEL BEFORE ZOD"
      end
    end
    
    context "but there's no custom subject" do
      it "should use the default" do
        @user.invite
        expect_subject "Your invitation to join the #{@demo.name}"
      end
    end
  end

  context "interpolation" do
    before(:each) do
      custom_html = <<-END_HTML
<p>You're invited you to play [game_name], [user]!</p>
<p>If you're smart you'll <a href="[invitation_url]">click here</a> and play.</p>
<p><a href="[invitation_url]">seriously dude click</a> I am not telling you again.</p>
      END_HTML

      custom_plain_text = <<-END_PLAIN_TEXT
You're invited you to play [game_name] in plain text, [user]!
If you're smart you'll go to [invitation_url] and play.
      END_PLAIN_TEXT

      custom_subject = "Play [game_name]! DO IT! WE COMMAND YOU [user]!"

      @custom_invitation_email = FactoryGirl.create(:custom_invitation_email, demo: @demo, custom_plain_text: custom_plain_text, custom_html_text: custom_html, custom_subject: custom_subject)
      @demo.update_attributes(name: "HealthAwesome")

      @user.invite
    end

    it "should interpolate the game and user name" do
      expect_subject("Play HealthAwesome! DO IT! WE COMMAND YOU #{@user.name}!")
      expect_email_content("play HealthAwesome, #{@user.name}!</p>")
      expect_email_content("play HealthAwesome in plain text, #{@user.name}!")
    end

    it "should interpolate invitation URLs" do
      expect_email_content("you'll go to #{invitation_url(@user.invitation_code)}")
    end

    context "when there is a referrer" do
      before(:each) do
        crank_dj_clear
        ActionMailer::Base.deliveries.clear

        custom_html = <<-END_HTML
<p>[referrer] has invited you to play [game_name]!</p>
<p>If you're smart you'll <a href="[invitation_url]">click here</a> and play.</p>
        END_HTML

        custom_plain_text = <<-END_PLAIN_TEXT
Plainly, [referrer] has invited you to play [game_name] in plain text!
If you're smart you'll go to [invitation_url] and play.
        END_PLAIN_TEXT

        custom_subject = "[referrer] says you'd better play [game_name]"

        @custom_invitation_email.update_attributes(custom_html_text: custom_html, custom_plain_text: custom_plain_text, custom_subject_with_referrer: custom_subject)
        @demo.custom_invitation_email.reload
        @user.invite(@referrer)
      end

      it "should interpolate the referrer name" do
        expect_email_content "<p>#{@referrer.name} has invited you"
        expect_email_content "Plainly, #{@referrer.name}"
        expect_subject "#{@referrer.name} says you'd better play HealthAwesome"
      end

      it "should interpolate invitation URLs with the referrer" do
        expect_email_content invitation_url(@user.invitation_code, :referrer_id => @referrer.id, :demo_id => @demo.id)
      end
    end
  end

  it "should get a footer with our address and an unsubscribe link, but no link to account settings" do
    @user.invite
    expect_email_content "Our mailing address is:"
    visit_in_email "unsubscribe"
    should_be_on new_unsubscribe_path

    expect_no_email_content email_account_settings_link
  end
end
