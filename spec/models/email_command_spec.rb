require 'spec_helper'
#  include Shoulda::Matchers::ActionMailer 

describe EmailCommand do
  it { should belong_to(:user) }
end

describe EmailCommand, "#status" do
  context "when status value is " do
    it "bad, it should not be valid" do
      email_command = (FactoryGirl.create :email_command)
      email_command.status = 'ima bad status'
      email_command.should_not be_valid
    end
    it "'failed', it should be valid" do
      (FactoryGirl.create :email_command, :status => EmailCommand::Status::FAILED).should be_valid 
    end
    it "'success', it should be valid" do
      (FactoryGirl.create :email_command, :status => EmailCommand::Status::SUCCESS).should be_valid 
    end
    it "'unknown email', it should be valid" do
      (FactoryGirl.create :email_command, :status => EmailCommand::Status::UNKNOWN_EMAIL).should be_valid 
    end
    it "'user verified', it should be valid" do
      (FactoryGirl.create :email_command, :status => EmailCommand::Status::USER_VERIFIED).should be_valid 
    end
  end
end

describe EmailCommand, "#users" do
  context "when associated user " do
    it "is nil, it should be valid" do
      email_command = (FactoryGirl.create :email_command)
      email_command.user = nil # defaults this way in this factory, but just to be clear
      email_command.should be_valid
    end
    it "is not nil, it should be valid" do
      email_command = (FactoryGirl.create :email_command, :user => (FactoryGirl.create :user) )
      email_command.should be_valid
    end
  end
end

describe EmailCommand, "#receiving" do
  context "when an email arrives " do
    it "should parse the params correctly and be valid" do
      email_command = EmailCommand.create_from_incoming_email(test_email_params)      
      email_command.email_to.should      eql test_email_params['to']
      email_command.email_from.should    eql test_email_params['from']
      email_command.email_subject.should eql test_email_params['subject']
      email_command.email_plain.should   eql test_email_params['plain']
      email_command.clean_body.should   eql "here's the command"
      email_command.status.should        eql EmailCommand::Status::UNKNOWN_EMAIL
    end
  end
end

describe EmailCommand, "#cleaning the command" do
  context "when an email arrives " do
    it "the plain part should always be parsed correctly" do
      p = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n\nhere's the      COMMAND\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n\nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t    HERE's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t    \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "here's \t\t the      command\t\t\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t   \n\n\n\n  \t \n \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n  \n\t  \t \t made toast  \t\t\nsecond line\n"
      EmailCommand.parse_email_body(p).should eql "made toast"
    end
  end
end

describe EmailCommand, "#cleaning email addresses" do
  context "when an email arrives " do
    it "the email address should be parsed correctly" do
      e = "Kevin Bedell <kbedell@gmail.com>"
      EmailCommand.clean_email_address(e).should eql "kbedell@gmail.com"
      e = "<kbedell@gmail.com>"
      EmailCommand.clean_email_address(e).should eql "kbedell@gmail.com"
      e = "kbedell@gmail.com"
      EmailCommand.clean_email_address(e).should eql "kbedell@gmail.com"
      e = "" # in case it's just missing
      EmailCommand.clean_email_address(e).should eql ""
    end
  end
end

describe EmailCommand, "#find user by email" do
  context "when an email arrives " do
    it "the user should be findable from the incoming email" do
      user = FactoryGirl.create :user
      test_params = test_email_params
      test_params['from'] = user.email
      test_params['from'].should eql user.email
      test_user = User.find_by_email(user.email).should eql user
      email_command = EmailCommand.create_from_incoming_email(test_params)
      email_command.user.should eql user
      email_command.status.should eql EmailCommand::Status::USER_VERIFIED
    end
  end
  context "when an email arrives from an unknown email " do
    it "we should save the command with the user value nil and status UNKNOWN_EMAIL" do
      test_params = test_email_params
      test_params['from'] = 'unknownemail@unknown.com'
      email_command = EmailCommand.create_from_incoming_email(test_params)
      email_command.user.should be_nil
      email_command.status.should eql EmailCommand::Status::UNKNOWN_EMAIL
    end
  end
end

describe EmailCommand, "#looks_like_autoresponder?" do
  it "should detect certain phrases in the subject" do
    triggering_phrases = [
      "Out of office",
      "out of office",
      "Out-of-office",
      "Out of the office",
      "out of the office",
      "Autoresponse",
      "Auto-response",
      "Automatic response",
      "automatic response",
      "auto-response",
      "Auto response",
      "On vacation",
      "on vacation"
    ]

    non_triggering_phrases = [
      "Four score and seven years ago",
      "In the office",
      "Totally back in the office"
    ]

    triggering_phrases.each do |triggering_phrase|
      params = test_email_params.merge('subject' => triggering_phrase)
      email_command = EmailCommand.create_from_incoming_email(params)
      email_command.looks_like_autoresponder?.should be_true
    end

    non_triggering_phrases.each do |non_triggering_phrase|
      params = test_email_params.merge(:subject => non_triggering_phrase)
      email_command = EmailCommand.create_from_incoming_email(params)
      email_command.looks_like_autoresponder?.should be_false
    end
  end
end

def test_email_params
 {  "to"=>"email_commands@hengage.net",
    "from"=>"kbedell@gmail.com",
    "subject"=>"I did something good!",
    "plain"=>"\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
  }
end


