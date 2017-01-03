require 'spec_helper'
#  include Shoulda::Matchers::ActionMailer

describe EmailCommand do
  it { is_expected.to belong_to(:user) }
end

describe EmailCommand, "#status" do
  context "when status value is " do
    it "bad, it should not be valid" do
      email_command = (FactoryGirl.create :email_command)
      email_command.status = 'ima bad status'
      expect(email_command).not_to be_valid
    end
    it "'failed', it should be valid" do
      expect(FactoryGirl.create :email_command, :status => EmailCommand::Status::FAILED).to be_valid
    end
    it "'success', it should be valid" do
      expect(FactoryGirl.create :email_command, :status => EmailCommand::Status::SUCCESS).to be_valid
    end
    it "'unknown email', it should be valid" do
      expect(FactoryGirl.create :email_command, :status => EmailCommand::Status::UNKNOWN_EMAIL).to be_valid
    end
    it "'user verified', it should be valid" do
      expect(FactoryGirl.create :email_command, :status => EmailCommand::Status::USER_VERIFIED).to be_valid
    end
  end
end

describe EmailCommand, "#users" do
  context "when associated user " do
    it "is nil, it should be valid" do
      email_command = (FactoryGirl.create :email_command)
      email_command.user = nil # defaults this way in this factory, but just to be clear
      expect(email_command).to be_valid
    end
    it "is not nil, it should be valid" do
      email_command = (FactoryGirl.create :email_command, :user => (FactoryGirl.create :user) )
      expect(email_command).to be_valid
    end
  end
end

describe EmailCommand, "#receiving" do
  context "when an email arrives " do
    it "should parse the params correctly and be valid" do
      email_command = EmailCommand.create_from_incoming_email(test_email_params)
      expect(email_command.email_to).to      eql test_email_params['to']
      expect(email_command.email_from).to    eql test_email_params['from']
      expect(email_command.email_subject).to eql test_email_params['subject']
      expect(email_command.email_plain).to   eql test_email_params['plain']
      expect(email_command.clean_body).to   eql "here's the command"
      expect(email_command.status).to        eql EmailCommand::Status::UNKNOWN_EMAIL
    end
  end
end

describe EmailCommand, "#cleaning the command" do
  context "when an email arrives " do
    it "the plain part should always be parsed correctly" do
      p = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n\nhere's the      COMMAND\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n\nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n \t    HERE's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n \t    \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "here's \t\t the      command\t\t\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n \t   \n\n\n\n  \t \n \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      expect(EmailCommand.parse_email_body(p)).to eql "here's the command"
      p = "\n  \n\t  \t \t made toast  \t\t\nsecond line\n"
      expect(EmailCommand.parse_email_body(p)).to eql "made toast"
    end
  end
end

describe EmailCommand, "#cleaning email addresses" do
  context "when an email arrives " do
    it "the email address should be parsed correctly" do
      e = "Kevin Bedell <kbedell@gmail.com>"
      expect(EmailCommand.clean_email_address(e)).to eql "kbedell@gmail.com"
      e = "<kbedell@gmail.com>"
      expect(EmailCommand.clean_email_address(e)).to eql "kbedell@gmail.com"
      e = "kbedell@gmail.com"
      expect(EmailCommand.clean_email_address(e)).to eql "kbedell@gmail.com"
      e = "" # in case it's just missing
      expect(EmailCommand.clean_email_address(e)).to eql ""
    end
  end
end

describe EmailCommand, "#find user by email" do
  context "when an email arrives " do
    it "the user should be findable from the incoming email" do
      user = FactoryGirl.create :user
      test_params = test_email_params
      test_params['from'] = user.email
      expect(test_params['from']).to eql user.email
      test_user = expect(User.find_by_email(user.email)).to eql user
      email_command = EmailCommand.create_from_incoming_email(test_params)
      expect(email_command.user).to eql user
      expect(email_command.status).to eql EmailCommand::Status::USER_VERIFIED
    end
  end
  context "when an email arrives from an unknown email " do
    it "we should save the command with the user value nil and status UNKNOWN_EMAIL" do
      test_params = test_email_params
      test_params['from'] = 'unknownemail@unknown.com'
      email_command = EmailCommand.create_from_incoming_email(test_params)
      expect(email_command.user).to be_nil
      expect(email_command.status).to eql EmailCommand::Status::UNKNOWN_EMAIL
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
      expect(email_command.looks_like_autoresponder?).to be_truthy
    end

    non_triggering_phrases.each do |non_triggering_phrase|
      params = test_email_params.merge(:subject => non_triggering_phrase)
      email_command = EmailCommand.create_from_incoming_email(params)
      expect(email_command.looks_like_autoresponder?).to be_falsey
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
