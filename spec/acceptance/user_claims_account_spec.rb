require 'acceptance/acceptance_helper'

metal_testing_hack(SmsController)

feature 'User claims account' do

  module SMSMethods
    def expect_welcome_message(user = nil)
      expected_user = user || @expected_user
      expect_mt_sms "+14152613077", "You've joined the #{expected_user.demo.name} game! Your username is #{expected_user.sms_slug} (text MYID if you forget). To play, text to this #."
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

    # This is a hack, since for some reason these modules have 
    # shared_examples_for defined but not context. Who can say?

    shared_examples_for "behaviors specific to SMS" do
      it "should not try to send a password reset message to an empty e-mail address" do
        ActionMailer::Base.deliveries.should be_empty

        user = FactoryGirl.create(:user, email: nil, claim_code: 'bob')
        send_message "bob"
        crank_dj_clear

        user.reload.should be_claimed
        ActionMailer::Base.deliveries.should be_empty
      end
    end
  end

  module EmailMethods
    before(:each) do
      ActionMailer::Base.deliveries.clear
    end

    def expect_welcome_message(user = nil)
      expected_user = user || @expected_user
      expect_reply "You've joined the #{expected_user.demo.name} game! If you'd like to play by e-mail instead of texting or going to the website, you can always send your commands to #{expected_user.reply_email_address(false)}.", expected_user.email
    end

    def send_message(message_text, to = nil)
      to ||= @expected_user.try(:demo).try(:email)
      email_originated_message_received("phil@darnowsky.com", "", message_text + "\n\n\n---\nPhil Darnowsky\nChief Technical Officer and Code Walloper\nH Engage, Inc.\n\n", to)
    end

    def send_message_to_other_demo(message_text)
      send_message(message_text, @other_demo.email)
    end

    def expect_reply(message_text, email="phil@darnowsky.com")
      crank_dj_clear
      open_email(email)
      current_email.to_s.should include(message_text)
      current_email.to_s.should include("---Please put replies ABOVE this line---")
      current_email.to_s.should include("Please note that we look for your command in the first line of the body of your email.")
    end

    def expect_contact_set(user)
      user.reload.email.should == "phil@darnowsky.com"
    end

    def expect_contact_unset(user)
      user.reload.phone_number.should_not == "phil@darnowsky.com"
    end

    def clear_messages
      crank_dj_clear
      ActionMailer::Base.deliveries.clear
    end

    def create_claimed_user
      FactoryGirl.create(:user, :claimed, email: "phil@darnowsky.com", points: 10)
    end

    shared_examples_for("email overflow or reclaim") do |priming_messages, retry_message, helpful_error_message|
      before(:each) do
        @expected_user.update_attributes(accepted_invitation_at: @original_claim_time, email: 'phil@hengage.com')
      end

      context "and the user has no overflow email set" do
        before(:each) do
          priming_messages.each do |priming_message|
            clear_messages
            send_message priming_message 
          end
        end

        it "should push the address in email to overflow_email and set email to the address that's mailing us" do
          @expected_user.reload
          @expected_user.email.should == 'phil@darnowsky.com'
          @expected_user.overflow_email.should == 'phil@hengage.com'
        end

        it "should not update accepted_invitation_at" do
          @expected_user.reload.accepted_invitation_at.to_s.should == @original_claim_time.to_s
        end

        it "should say something helpful" do
          expect_reply "OK, we've got your new email address phil@darnowsky.com, and will still remember phil@hengage.com too.", "phil@darnowsky.com"
        end
      end

      context "and the user has an overflow email set" do
        before(:each) do
          @expected_user.update_attributes(overflow_email: 'phil@hengage.com', email: 'pdarnows@yahoo.com')
          priming_messages.each do |priming_message|
            clear_messages
            send_message priming_message 
          end
        end

        it "should send back a helpful error message" do
          expect_reply helpful_error_message
        end

        it "should let the user try again" do
          clear_messages
          send_message retry_message
          @other_user.reload.should be_claimed
          expect_welcome_message(@other_user)
        end

        it "should not re-claim that user" do
          @expected_user.reload
          @expected_user.accepted_invitation_at.utc.to_s.should == @original_claim_time.utc.to_s
          expect_contact_unset @expected_user
        end              
      end

    end
  end

  [
    ["SMS", SMSMethods],
    ["email", EmailMethods]
  ].each do |channel_name, channel_module|
    context "by #{channel_name}" do
      include channel_module

      def expect_referral_still_works
        clear_messages
        send_message "referrer"
        @expected_user.reload.game_referrer.should == @expected_referrer
        expect_reply "Got it, #{@expected_referrer.name} referred you to the game. Thanks for letting us know."
      end

      if(channel_name == 'SMS')
        # See comment up by shared_examples_for "behaviors specific to SMS"
        # to see why we do this silly thing.
        it_should_behave_like "behaviors specific to SMS"
      end

      context "when the contact in question is not associated with a user yet" do
        before(:each) do
          @demo = FactoryGirl.create(:demo, :name => "Global Tetrahedron", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 1000, :email => 'gtet@playhengage.com', :phone_number => "+19085551212")
          FactoryGirl.create(:claim_state_machine, :states => ClaimStateMachine::PredefinedMachines::COVIDIEN_THREE_STEP_STYLE, :demo => @demo)

          @other_demo = FactoryGirl.create(:demo, :name => "Amalgamated Consolidated", :credit_game_referrer_threshold => 60, :game_referrer_bonus => 1000, :email => 'ac@playhengage.com', :phone_number => "+12155551212")
          FactoryGirl.create(:claim_state_machine, :states => ClaimStateMachine::PredefinedMachines::COVIDIEN_THREE_STEP_STYLE, :demo => @other_demo)

          @expected_user = FactoryGirl.create(:user, :demo => @demo, :claim_code => "bob", :email => '')
          @expected_user.should_not be_claimed
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
              @original_claim_time = Time.now - 1.week
              @expected_user.update_attributes(accepted_invitation_at: @original_claim_time, email: 'phil@hengage.com')
              @other_user = FactoryGirl.create(:user, demo: @demo, claim_code: "fred")
            end

            if(channel_name == "SMS")
              before(:each) do
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
            else
              it_should_behave_like "email overflow or reclaim", %w(bob), "fred", %(That ID "bob" is already taken. If you're trying to register your account, please send in your own ID first by itself.)
            end
          end

          context "and that user has a twin in another demo with similar rules" do
            before(:each) do
              @twin = FactoryGirl.create(:user, demo: @other_demo, email: '', claim_code: 'bob')
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
              @original_claim_time = Time.now - 1.week
              @expected_user.update_attributes(accepted_invitation_at: @original_claim_time)
            end

            if(channel_name == "SMS")
              before(:each) do
                send_message "bob"
                clear_messages
                send_message "02139"
              end

              it "should send back a helpful error message" do
                expect_reply "It looks like that account is already claimed. Please try a different ZIP code, or contact support@hengage.com for help."
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
            else
              it_should_behave_like "email overflow or reclaim", %w(bob 02139), "94110", "It looks like that account is already claimed. Please try a different ZIP code, or contact support@hengage.com for help."
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
              expect_reply "Sorry, I don't recognize that ZIP code. Please try a different one, or contact support@hengage.com for help."
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
            end

            if(channel_name == "SMS")
              before(:each) do
                send_message "bob"
                send_message "02139"
                clear_messages

                send_message "0910"
              end

              it "should send back a helpful error message" do
                expect_reply "It looks like that account is already claimed. Please try a different date of birth, or contact support@hengage.com for help."
              end

              it "should let the user try again" do
                clear_messages
                send_message "0911"
                @other_user.reload.should be_claimed
                expect_welcome_message(@other_user)
              end

              it "should not re-claim that user" do
                @expected_user.reload
                @expected_user.accepted_invitation_at.should == @original_claim_time
                expect_contact_unset @expected_user
              end
            else
              it_should_behave_like "email overflow or reclaim", %w(bob 02139 0910), "0911", "It looks like that account is already claimed. Please try a different date of birth, or contact support@hengage.com for help."
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
              expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@hengage.com for help joining the game. Thank you!"
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
            expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@hengage.com for help joining the game. Thank you!"
          end

          it "should allow them to try another one" do
            send_message "0911"
            clear_messages
            send_message "0910"
            @expected_user.reload.should be_claimed
            expect_welcome_message
          end

          it "should notify admins to watch for this user" do
            ActionMailer::Base.deliveries.should be_empty
            send_message "0911"
            crank_dj_clear

            ActionMailer::Base.deliveries.should_not be_empty
            open_email("supporters@hengage.com")
            [@ambiguous_1, @ambiguous_2].each do |candidate|
              current_email.body.should include(candidate.name)
              current_email.body.should include(candidate.date_of_birth.to_s)
            end
          end
        end
      end

      context "when the contact in question is associated with a user" do
        before(:each) do
          create_claimed_user
          FactoryGirl.create(:user, :claim_code => 'otherguy')
        end

        it "should send a helpful error message" do
          send_message 'otherguy'
          expect_reply "You've already claimed your account, and have 10 pts. If you're trying to credit another user, ask them to check their username with the MYID command."
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
          expect_reply "It looks like that account is already claimed. Please try again, or contact support@hengage.com for help."

          clear_messages
          send_message 'duplicate'
          @ambiguous_user_1.reload.should_not be_claimed
          @ambiguous_user_2.reload.should_not be_claimed
          expect_reply "Sorry, we're having a little trouble, it looks like we'll have to get a human involved. Please contact support@hengage.com for help joining the game. Thank you!"

          clear_messages
          [@expected_user, @evil_twin, @other_user].each{|u| u.should_not be_claimed}
          send_message 'sven'
          @expected_user.reload.should be_claimed
          [@evil_twin, @other_user].each{|u| u.reload.should_not be_claimed}
          expect_welcome_message
        end
      end
    end
  end

  it "should have unsubscribe links but not account settings links"
end
