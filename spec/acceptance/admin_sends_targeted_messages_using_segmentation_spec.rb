require 'acceptance/acceptance_helper'

feature 'Admin sends targeted messges using segmentation' do
  def set_up_models(options={})
    user_model_name = options[:use_phone] ? :user_with_phone : :user

    @demo = FactoryGirl.create :demo
    @users = []
    20.times {|i| @users << FactoryGirl.create(user_model_name, points: i, demo: @demo)}
    # Also let's make some users in a different demo to make sure we don't get
    # leakage.
    5.times {FactoryGirl.create(user_model_name)}

    @agnostic_characteristic = FactoryGirl.create(:characteristic, name: "Metasyntactic variable", allowed_values: %w(foo bar baz))
    @demo_specific_characteristic = FactoryGirl.create(:characteristic, :number)

    10.upto(19) {|i| @users[i].update_attributes(characteristics: {@agnostic_characteristic.id.to_s => %w(foo bar baz)[i % 3], @demo_specific_characteristic.id.to_s => i % 5})}
    crank_dj_clear
  end

  def select_common_form_entries
    signin_as_admin

    visit admin_demo_targeted_messages_path(@demo)

    select 'Metasyntactic variable', :from => "segment_column[0]"
    select "does not equal", :from => "segment_operator[0]"
    select "foo", :from => "segment_value[0]"

    click_link "Segment on more characteristics"
    select "Points", :from => "segment_column[1]"
    select "greater than", :from => "segment_operator[1]"
    fill_in "segment_value[1]", :with => "10"

    click_button "Find segment"

    should_be_on(admin_demo_targeted_messages_path(@demo))
    expect_content "6 users in segment"
    expect_content "Segmenting on: Metasyntactic variable does not equal foo, Points is greater than 10"
    @expected_users = [11, 13, 14, 16, 17, 19].map{|i| @users[i]}
  end

  def ensure_expected_mails_sent(expected_subject, expected_html_text, expected_plain_text, options={})
    expected_mail_count = options[:mail_count] || 6

    click_button "It's going to be OK"
    expect_content "Scheduled email to #{expected_mail_count} users"

    crank_dj_clear
    ActionMailer::Base.deliveries.length.should == expected_mail_count
    ActionMailer::Base.deliveries.each do |mail| 
      html_part = mail.parts.select{|part| part.content_type =~ /html/}.first
      plain_part = mail.parts.select{|part| part.content_type =~ /text/}.first

      mail.subject.should == expected_subject
      html_part.body.to_s.should include(expected_html_text)
      plain_part.body.to_s.should include(expected_plain_text)
    end
  end

  context "when an explicit plain text is given" do
    it "should use that", :js => true do
      set_up_models
      select_common_form_entries

      expected_subject = "Hello friends!"
      expected_html_text = "<p>Did you know?</p><p>H Engage is AWESOME.</p>"
      expected_plain_text = "Seriously, it is the cat's pajamas.\n\nPajamas!\n\n"

      fill_in "subject",    :with => expected_subject
      fill_in "html_text",  :with => expected_html_text
      fill_in "plain_text", :with => expected_plain_text

      ensure_expected_mails_sent(expected_subject, expected_html_text, expected_plain_text)
    end
  end

  it "should not try sending email if both email text fields are blank", :js => true do
    set_up_models
    select_common_form_entries

    fill_in "subject", :with => "blankness"

    click_button "It's going to be OK"
    expect_content "Email text blank, no emails sent"

    crank_dj_clear
    ActionMailer::Base.deliveries.should be_empty
  end

  context "when plain text field is all whitespace and HTML text field has no non-whitespace text" do
    it "should not send an email", :js => true do
      set_up_models
      select_common_form_entries
      fill_in "subject", :with => "blankitude"
      fill_in "html_text", :with => "<p>     </p><br/><br/><p></p>"
      fill_in "plain_text", :with => "\n\n\n        \n\n"

      click_button "It's going to be OK"
      expect_content "Email text blank, no emails sent"

      crank_dj_clear
      ActionMailer::Base.deliveries.should be_empty
    end

    context "but the HTML text field has got an image in it" do
      it "should send an email", :js => true do
        set_up_models
        select_common_form_entries
        fill_in "subject", :with => "blankitude"
        fill_in "html_text", :with => "<p>     </p><img src=\"foobar\"><br/><br/><p></p>"
        fill_in "plain_text", :with => "\n\n\n        \n\n"

        click_button "It's going to be OK"
        expect_no_content "Email text blank, no emails sent"

        crank_dj_clear
        ActionMailer::Base.deliveries.should_not be_empty
      end
    end
  end

  it "should allow texts to be sent", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    expected_sms_text = "Here is a text message! Yay!"
    fill_in "sms_text", :with => expected_sms_text

    click_button "It's going to be OK"
    expect_content "Email text blank, no emails sent"
    expect_content "Scheduled SMS to 6 users"

    crank_dj_clear

    @expected_users.each do |expected_user|
      expect_mt_sms expected_user.phone_number, expected_sms_text
    end
  end

  it "should not try sending an SMS if the SMS text is blank", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    click_button "It's going to be OK"
    expect_content "SMS text blank, no SMSes sent"

    crank_dj_clear

    FakeTwilio.sent_messages.should be_empty
  end

  it "should have helpful messages if email text and sms text are all blank", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    click_button "It's going to be OK"

    expect_content "Email text blank, no emails sent"
    expect_content "SMS text blank, no SMSes sent"

    crank_dj_clear
    ActionMailer::Base.deliveries.should be_empty
    FakeTwilio.sent_messages.should be_empty
  end
  
  it "should allow both emails and SMSes to be sent at the same time", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    expected_html_text = "<p>Be advised!</p>"
    expected_sms_text = "be u advised"

    fill_in "html_text", :with => expected_html_text
    fill_in "sms_text", :with => expected_sms_text
    click_button "It's going to be OK"

    expect_content "Scheduled email to 6 users"
    expect_content "Scheduled SMS to 6 users"

    crank_dj_clear
    ActionMailer::Base.deliveries.length.should == 6
    FakeTwilio.sent_messages.length.should == 6
  end

  it 'should respect notification preferences by default', :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    @expected_users.each_with_index do |expected_user, i|
      expected_user.update_attributes(notification_method: %w(both email sms)[i % 3])
    end

    expected_html_text = "<p>Be advised!</p>"
    expected_sms_text = "be u advised"

    fill_in "html_text", :with => expected_html_text
    fill_in "sms_text", :with => expected_sms_text
    click_button "It's going to be OK"

    expect_content "Scheduled email to 4 users"
    expect_content "Scheduled SMS to 4 users"

    crank_dj_clear

    sms_users = @expected_users.select{|u| u.notification_method == 'sms' || u.notification_method == 'both'}
    email_users = @expected_users.select{|u| u.notification_method == 'email' || u.notification_method == 'both'}

    ActionMailer::Base.deliveries.map(&:to).flatten.sort.should == email_users.map(&:email).sort
    FakeTwilio.sent_messages.map{|sms| sms['To']}.sort.should == sms_users.map(&:phone_number).sort
  end

  it 'should allow override of notification preferences and send to everyone possible', :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    @expected_users.each_with_index do |expected_user, i|
      expected_user.update_attributes(notification_method: %w(both email sms)[i % 3])
    end

    expected_html_text = "<p>Be advised!</p>"
    expected_sms_text = "be u advised"

    fill_in "html_text", :with => expected_html_text
    fill_in "sms_text", :with => expected_sms_text
    uncheck "Respect notification method"
    click_button "It's going to be OK"

    expect_content "Scheduled email to 6 users"
    expect_content "Scheduled SMS to 6 users"

    crank_dj_clear
    ActionMailer::Base.deliveries.should have(6).emails
    FakeTwilio.sent_messages.should have(6).texts
  end

  it "should have a link from somewhere in the admin side" do
    demo = FactoryGirl.create(:demo)
    signin_as_admin

    visit admin_demo_path(demo)
    click_link "Send targeted messages to users in this demo"
    should_be_on admin_demo_targeted_messages_path(demo)
  end

  it "should keep the message fields filled in after a new segmentation", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    expected_html_text = "<p>Be advised!</p>"
    expected_plain_text = "Plainly take advice"
    expected_sms_text = "be u advised"

    fill_in "html_text", :with => expected_html_text
    fill_in "plain_text", :with => expected_plain_text
    fill_in "sms_text", :with => expected_sms_text

    select "Metasyntactic variable", :from => "segment_column[0]"
    select "equals", :from => "segment_operator[0]"
    select "foo", :from => "segment_value[0]"
    click_button "Find segment"

    expect_content "3 users in segment"

    expect_value "html_text", expected_html_text
    expect_value "plain_text", expected_plain_text
    expect_value "sms_text", expected_sms_text
  end

  it "should keep the message fields filled in after sending a message", :js => true do
    set_up_models(use_phone: true)
    select_common_form_entries

    expected_subject = "Some advice from your friends at The H Engages"
    expected_html_text = "<p>Be advised!</p>"
    expected_plain_text = "Plainly take advice"
    expected_sms_text = "be u advised"

    fill_in "subject", :with => expected_subject
    fill_in "html_text", :with => expected_html_text
    fill_in "plain_text", :with => expected_plain_text
    fill_in "sms_text", :with => expected_sms_text

    click_button "It's going to be OK"

    expect_content "Scheduled email to 6 users"
    expect_content "Scheduled SMS to 6 users"
   
    expect_value "subject", expected_subject
    expect_value "html_text", expected_html_text
    expect_value "plain_text", expected_plain_text
    expect_value "sms_text", expected_sms_text
  end

  it "should not attempt to send an SMS to a user with a blank phone number", :js => true do
    set_up_models(use_phone: true)
    3.times {FactoryGirl.create(:user, demo: @demo)}
    signin_as_admin

    visit admin_demo_targeted_messages_path(@demo)
    click_button "Find segment"

    should_be_on(admin_demo_targeted_messages_path(@demo))
    expect_content "23 users in segment"

    fill_in "sms_text", :with => 'some nonsense'
    click_button "It's going to be OK"

    expect_content "Scheduled SMS to 20 users"

    crank_dj_clear
    FakeTwilio.sent_messages.should have(20).texts
  end

  it "should not show a misleading error message after scheduling a long email", :js => true do
    set_up_models
    signin_as_admin
    visit admin_demo_targeted_messages_path(@demo)
    click_button "Find segment"

    mail_subject = "A selection from \"Three Men In A Boat\""
    long_text = File.read(Rails.root.join %w(spec support fixtures three_men_in_a_boat_four_paragraphs.txt).join('/'))
    sms_text = "Go read \"Three Men In A Boat\""

    fill_in "html_text", :with => long_text
    fill_in "plain_text", :with => long_text
    fill_in "subject", :with => mail_subject
    fill_in "sms_text", :with => sms_text

    click_button "It's going to be OK"
    page.status_code.should_not == 500
    page.find('#html_text').value.should == long_text
    page.find('#plain_text').value.should == long_text
    page.find('#subject').value.should == mail_subject
    page.find('#sms_text').value.should == sms_text
  end

  #it 'should allow a communication to be tracked after the fact'
end
