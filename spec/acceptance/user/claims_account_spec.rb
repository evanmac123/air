require 'acceptance/acceptance_helper'
# FIXME this functionality is probably no longer used. Remove test once that is
# confirmed.! HR 2015-07-26

metal_testing_hack(SmsController)

feature 'User claims account' do
  def expect_welcome_message(user = nil)
    expected_user = user || @expected_user
    expect_mt_sms "+14152613077", "You've joined the #{expected_user.demo.name} game! Your username is #{expected_user.sms_slug} (text MYID if you forget). Text to this #."
  end

  def send_message(message_text, to_number = nil)
    to_number ||= @expected_user.try(:demo).try(:phone_number)
    mo_sms "+14152613077", message_text, to_number
  end

  def send_message_to_other_demo(message_text)
    mo_sms "+14152613077", message_text, @other_demo.phone_number
  end

  def expect_reply(message_text)
    expect_mt_sms "+14152613077", message_text
  end

  def expect_reply_including(message_text)
    expect_mt_sms_including "+14152613077", message_text
  end

  def expect_no_reply_including(message_text)
    expect_no_mt_sms_including "+14152613077", message_text
  end

  def expect_contact_set(user)
    user.reload.phone_number.should == "+14152613077"
  end

  def expect_contact_unset(user)
    user.reload.phone_number.should_not == "+14152613077"
  end

  def clear_messages
    FakeTwilio.clear_messages
  end

  def create_claimed_user
    FactoryGirl.create(:user, :claimed, phone_number: "+14152613077", points: 10)
  end

  def expect_referral_still_works
    clear_messages
    send_message "referrer"
    @expected_user.reload.game_referrer.should == @expected_referrer
    expect_reply "Got it, #{@expected_referrer.name} recruited you. Thanks for letting us know."
  end

  #FIXME this looks like a unit test to me.
  it "should not try to send a password reset message to an empty e-mail address" do
    ActionMailer::Base.deliveries.should be_empty

    user = FactoryGirl.create(:user, email: nil, official_email: "yada@doo.com", claim_code: 'bob')
    user.notification_method.should == 'email'
    send_message "bob"
    crank_dj_clear

    user.reload.should be_claimed
    user.notification_method.should == 'sms'
    ActionMailer::Base.deliveries.should be_empty
  end

  context "when the contact in question is not associated with a user yet" do
    before(:each) do
      @demo = FactoryGirl.create(:demo, :name => "Global Tetrahedron", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 1000, :email => 'gtet@playhengage.com', :phone_number => "+19085551212")
      FactoryGirl.create(:claim_state_machine, :states => ClaimStateMachine::PredefinedMachines::COVIDIEN_THREE_STEP_STYLE, :demo => @demo)

      @other_demo = FactoryGirl.create(:demo, :name => "Amalgamated Consolidated", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 1000, :email => 'ac@playhengage.com', :phone_number => "+12155551212")
      FactoryGirl.create(:claim_state_machine, :states => ClaimStateMachine::PredefinedMachines::COVIDIEN_THREE_STEP_STYLE, :demo => @other_demo)

      @expected_user = FactoryGirl.create(:user, :demo => @demo, :claim_code => "bob", :email => nil, :official_email => 'babba@boowee.com')
      @expected_referrer = FactoryGirl.create(:user, :demo => @demo)
      @expected_referrer.update_attributes(:sms_slug => "referrer")
    end

    context "and the claim code uniquely identifies one single user" do
      it "should claim that account when user sends in claim code" do
        send_message "bob"
        @expected_user.reload

        @expected_user.should be_claimed
        expect_contact_set @expected_user
        expect_welcome_message
      end

      it "should not break referring" do
        send_message "bob"
        expect_referral_still_works
      end

      context "and that user is claimed already" do
        before(:each) do
          @original_claim_time = Time.zone.now - 1.week
          @expected_user.update_attributes(accepted_invitation_at: @original_claim_time, email: 'phil@hengage.com')
          @other_user = FactoryGirl.create(:user, demo: @demo, claim_code: "fred")
          send_message "bob"
        end

        it "should send back a helpful error message" do
          expect_reply %(That ID "bob" is already taken. If you're trying to register your account, please send in your own ID first by itself.)
        end

        it "should let the user try again" do
          clear_messages
          send_message "fred"
          @other_user.reload.should be_claimed
          expect_welcome_message(@other_user)
        end

        it "should not re-claim that user" do
          @expected_user.reload
          @expected_user.accepted_invitation_at.to_s.should == @original_claim_time.to_s
          expect_contact_unset @expected_user
        end
      end

      context "and that user has a twin in another demo with similar rules" do
        before(:each) do
          @twin = FactoryGirl.create(:user, demo: @other_demo, email: '', official_email: "ladi@dadi.com", claim_code: 'bob')
        end

        it "should claim the correct account, depending where the incoming message goes to" do
          send_message_to_other_demo('bob')
          @expected_user.reload.should_not be_claimed
          @twin.reload.should be_claimed
        end
      end
    end

    ['b ob', 'b. ob', '"bob"', 'B. Ob'].each do |claim_code_variation|
      scenario "#{claim_code_variation} is an acceptable variation on the claim code" do
        send_message claim_code_variation
        @expected_user.reload.should be_claimed
      end
    end

    context "and the claim code sent identifies no user" do
      it "should reply with a sensible error message" do
        send_message "someotherguy"

        @expected_user.reload.should_not be_claimed
        expect_reply "I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send \"jsmith\")."
      end
    end

    context "and the claim code doesn't uniquely identify a user, but claim code + ZIP code do" do
      before(:each) do
        @expected_user.update_attributes(zip_code: '02139')
        @other_user = FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '94110', demo: @expected_user.demo)
      end

      it "should claim the user when we get both pieces of information" do
        send_message "bob"
        @expected_user.reload

        @expected_user.should_not be_claimed
        expect_reply "Sorry, we need a little more information to figure out who you are. Please send your 5-digit home ZIP code."

        clear_messages

        send_message "02139"
        @expected_user.reload
        @expected_user.should be_claimed
        expect_welcome_message
      end

      it "should not break referring" do
        send_message "bob"
        send_message "02139"
        expect_referral_still_works
      end

      context "and that user is claimed already" do
        before(:each) do
          @original_claim_time = Time.zone.now - 1.week
          @expected_user.update_attributes(accepted_invitation_at: @original_claim_time)

          send_message "bob"
          clear_messages
          send_message "02139"
        end

        it "should send back a helpful error message" do
          expect_reply "It looks like that account is already claimed. Please try a different ZIP code, or contact support@airbo.com for help."
        end

        it "should let the user try again" do
          clear_messages
          send_message "94110"
          @other_user.reload.should be_claimed
          expect_welcome_message(@other_user)
        end

        it "should not re-claim that user" do
          @expected_user.reload
          @expected_user.accepted_invitation_at.to_s.should == @original_claim_time.to_s
          expect_contact_unset @expected_user
        end
      end

      context "and the user can't do a simple thing like entering a zip code right" do
        before(:each) do
          send_message "bob"
          clear_messages
          send_message "02DERPDERPDERP"
        end

        it "should let them try again" do
          clear_messages
          send_message "02139"
          @expected_user.reload.should be_claimed
          expect_welcome_message
        end

        it "should send a sensible error message" do
          expect_reply "Sorry, I didn't quite get that. Please send your 5-digit ZIP code."
        end
      end

      context "and the ZIP code sent identifies no user" do
        before(:each) do
          send_message "bob"
          clear_messages
          send_message "30303"
        end

        it "should reply with a sensible error message" do
          expect_reply "Sorry, I don't recognize that ZIP code. Please try a different one, or contact support@airbo.com for help."
        end

        it "should allow them to try another one" do
          clear_messages
          send_message "02139"
          @expected_user.reload.should be_claimed
          expect_welcome_message
        end
      end
    end

    context "and it takes claim code, ZIP and birth month/day to uniquely identify the user" do
      before(:each) do
        @expected_user.update_attributes(zip_code: "02139", date_of_birth: Date.parse("September 10, 1977"))
        FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '21201', date_of_birth: Date.parse("September 10, 1977"), demo: @expected_user.demo)
        @other_user = FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '02139', date_of_birth: Date.parse("September 11, 1974"), demo: @expected_user.demo)
        FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '02139', date_of_birth: Date.parse("April 17, 1977"), demo: @expected_user.demo)
      end

      it "should claim the user when we get all three pieces of information" do
        send_message "bob"
        @expected_user.reload

        @expected_user.should_not be_claimed
        expect_reply "Sorry, we need a little more information to figure out who you are. Please send your 5-digit home ZIP code."

        clear_messages

        send_message "02139"
        @expected_user.reload

        @expected_user.should_not be_claimed
        expect_reply "Sorry, we need a little more info to create your account. Please send your month & day of birth (format: MMDD)."

        clear_messages
        send_message "0910"
        @expected_user.reload

        @expected_user.should be_claimed
      end

      it "should not break referring" do
        send_message "bob"
        send_message "02139"
        send_message "0910"
        expect_referral_still_works
      end

      context "and that user is claimed already" do
        before(:each) do
          @original_claim_time = Time.now - 1.week
          @expected_user.update_attributes(accepted_invitation_at: @original_claim_time)

          send_message "bob"
          send_message "02139"
          clear_messages

          send_message "0910"
        end

        it "should send back a helpful error message" do
          expect_reply "It looks like that account is already claimed. Please try a different date of birth, or contact support@airbo.com for help."
        end

        it "should let the user try again" do
          clear_messages
          send_message "0911"
          @other_user.reload.should be_claimed
          expect_welcome_message(@other_user)
        end

        it "should not re-claim that user" do
          @expected_user.reload
          @expected_user.accepted_invitation_at.utc.to_s.should == @original_claim_time.utc.to_s
          expect_contact_unset @expected_user
        end
      end

      context "and the MMDD sent identifies no user" do
        before(:each) do
          send_message "bob"
          send_message "02139"
          clear_messages
          send_message "1225"
        end

        it "should reply with a sensible error message" do
          expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!"
        end

        it "should allow the user to try again" do
          @other_user.should_not be_claimed
          clear_messages
          send_message "0911"
          @other_user.reload.should be_claimed
          expect_welcome_message(@other_user)
        end
      end

      context "and the user does not understand our perfectly clear instructions regarding format" do
        before(:each) do
          send_message "bob"
          send_message "02139"
          clear_messages
        end

        context "and sends us something other than 4 characters" do
          before(:each) do
            send_message "SEP10th"
            @expected_user.reload.should_not be_claimed
          end

          it "should send an appropriate error message" do
            expect_reply "Sorry, I didn't quite get that. Please send your month & date of birth as MMDD (example: September 10 = 0910)."
          end

          it "should allow them to try again" do
            clear_messages

            send_message "0910"
            @expected_user.reload.should be_claimed
          end
        end

        context "and sends us 4 characters, not all of which are digits" do
          before(:each) do
            send_message "O91O" # that's a capital O
            @expected_user.reload.should_not be_claimed
          end

          it "should send an appropriate error message" do
            expect_reply "Sorry, I didn't quite get that. Please send your month & date of birth as MMDD (example: September 10 = 0910)."
          end

          it "should allow them to try again" do
            clear_messages

            send_message "0910"
            @expected_user.reload.should be_claimed
          end
        end
      end
    end

    context "and even claim code, ZIP and birthdate together are not enough" do
      before(:each) do
        @expected_user.update_attributes(zip_code: "02139", date_of_birth: Date.parse("September 10, 1977"))
        @ambiguous_1 = FactoryGirl.create(:user, name: "Some Guy", claim_code: @expected_user.claim_code, zip_code: '02139', date_of_birth: Date.parse("September 11, 1974"), demo: @expected_user.demo)
        @ambiguous_2 = FactoryGirl.create(:user, name: "Some Other Guy", claim_code: @expected_user.claim_code, zip_code: '02139', date_of_birth: Date.parse("September 11, 1984"), demo: @expected_user.demo)
        FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '21201', date_of_birth: Date.parse("September 10, 1977"), demo: @expected_user.demo)
        FactoryGirl.create(:user, claim_code: @expected_user.claim_code, zip_code: '02139', date_of_birth: Date.parse("April 17, 1977"), demo: @expected_user.demo)

        send_message "bob"
        send_message "02139"
      end

      it "should send back a sensible error message" do
        clear_messages
        send_message "0911"
        @expected_user.reload.should_not be_claimed
        expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!"
      end

      it "should allow them to try another one" do
        send_message "0911"
        clear_messages
        send_message "0910"
        @expected_user.reload.should be_claimed
        expect_welcome_message
      end
    end
  end

  context "when the contact in question is associated with a user" do
    before(:each) do
      @user = create_claimed_user
      @other_user = FactoryGirl.create(:user, :claim_code => 'otherguy', demo: @user.demo)
      FactoryGirl.create(:user, claim_code: "badguy")
    end

    it "should send a helpful error message" do
      send_message 'otherguy', "playhengage@example.com"
      expect_reply "You've already claimed your account, and have 10 pts. If you're trying to credit another user, ask them to check their username with the MYID command."
    end

    it "should not send an already-claimed message if it looks like the user is trying to claim an account in a different demo entirely" do
      send_message "badguy"
      expect_no_reply_including "You've already claimed your account"
      expect_reply_including %{Sorry, I don't understand}
    end

    context "and the demo has a custom already-claimed message" do
      before(:each) do
        @user.demo.update_attributes(custom_already_claimed_message: "You're in, Flynn, with %{points} points. It's cool.")
      end

      it "should use that" do
        send_message 'otherguy', "playhengage@example.com"
        expect_reply "You're in, Flynn, with 10 points. It's cool."
      end
    end
  end

  context "in a demo with default claiming" do
    before(:each) do
      @default_demo = FactoryGirl.create(:demo, :with_email, :with_phone_number)

      @expected_user = FactoryGirl.create(:user, demo: @default_demo, claim_code: 'sven')

      @evil_twin = FactoryGirl.create(:user, claim_code: 'sven')
      @evil_twin.demo.should_not == @expected_user.demo

      @ambiguous_user_1 = FactoryGirl.create(:user, demo: @default_demo, claim_code: 'duplicate')
      @ambiguous_user_2 = FactoryGirl.create(:user, demo: @default_demo, claim_code: 'duplicate')

      @other_user = FactoryGirl.create(:user, demo: @default_demo, claim_code: 'lars')
      @claimed_user = FactoryGirl.create(:user, :claimed, demo: @default_demo, claim_code: 'beethoven', overflow_email: 'hey@example.com')
    end

    it "should act in the old-school fashion" do
      send_message 'ohaithere'
      expect_reply "I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send \"jsmith\")."

      clear_messages
      send_message 'ohaithere'
      expect_reply "I can't find you in my records. Did you claim your account yet? If not, send your first initial and last name (if you are John Smith, send \"jsmith\")."

      clear_messages
      send_message 'beethoven'
      expect_reply "It looks like that account is already claimed. Please try again, or contact support@airbo.com for help."

      clear_messages
      send_message 'duplicate'
      @ambiguous_user_1.reload.should_not be_claimed
      @ambiguous_user_2.reload.should_not be_claimed
      expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@airbo.com for help joining the game. Thank you!"

      clear_messages
      [@expected_user, @evil_twin, @other_user].each{|u| u.should_not be_claimed}
      send_message 'sven'
      @expected_user.reload.should be_claimed
      [@evil_twin, @other_user].each{|u| u.reload.should_not be_claimed}
      expect_welcome_message
    end
  end
end
