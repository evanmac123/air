require 'spec_helper'
#  include Shoulda::Matchers::ActionMailer 

describe EmailCommand do
  it { should belong_to(:user) }
end

describe EmailCommand, "#status" do
  context "when status value is " do
    it "bad, it should not be valid" do
      email_command = (Factory :email_command)
      email_command.status = 'ima bad status'
      email_command.should_not be_valid
    end
    it "'new', it should be valid" do
      (Factory :email_command, :status => EmailCommand::Status::NEW).should be_valid 
    end
    it "'failed', it should be valid" do
      (Factory :email_command, :status => EmailCommand::Status::FAILED).should be_valid 
    end
    it "'success', it should be valid" do
      (Factory :email_command, :status => EmailCommand::Status::SUCCESS).should be_valid 
    end
  end
end

describe EmailCommand, "#users" do
  context "when associated user " do
    it "is nil, it should be valid" do
      email_command = (Factory :email_command)
      email_command.user = nil # defaults this way in this factory, but just to be clear
      email_command.should be_valid
    end
    it "is not nil, it should be valid" do
      email_command = (Factory :email_command_with_user)
      email_command.should be_valid
    end
  end
end

describe EmailCommand, "#subjects" do
  context "when associated user " do
    it "is nil, it should be valid" do
      email_command = (Factory :email_command)
      email_command.user = nil # defaults this way in this factory, but just to be clear
      email_command.should be_valid
    end
    it "is not nil, it should be valid" do
      email_command = (Factory :email_command_with_user)
      email_command.should be_valid
    end
  end
end

describe EmailCommand, "#subjects" do
  context "when associated user " do
    it "is nil, it should be valid" do
      email_command = (Factory :email_command)
      email_command.user = nil # defaults this way in this factory, but just to be clear
      email_command.should be_valid
    end
    it "is not nil, it should be valid" do
      email_command = (Factory :email_command_with_user)
      email_command.should be_valid
    end
  end
end

describe EmailCommand, "#receiving" do
  context "when an email arrives " do
    it "should parse the params correctly and be valid" do
      email_command = EmailCommand.create_from_incoming_email(email_sent_in)      
      email_command.email_to.should      eql email_sent_in['to']
      email_command.email_from.should    eql email_sent_in['from']
      email_command.email_subject.should eql email_sent_in['subject']
      email_command.email_plain.should   eql email_sent_in['plain']
      email_command.clean_command_string.should   eql "here's the command"
      email_command.status.should        eql EmailCommand::Status::NEW
    end
  end
end


def email_sent_in
 {  "to"=>"email_commands@hengage.net",
    "from"=>"kbedell@gmail.com",
    "subject"=>"I did something good!",
    "plain"=>"\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
  }
end

describe EmailCommand, "#cleaning the command" do
  context "when an email arrives " do
    it "the plain part should always be parsed correctly" do
      p = "\n\nhere's the command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n\nhere's the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n\nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t    \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t    \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "here's \t\t the      command\t\t\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
      p = "\n \t   \n\n\n\n  \t \n \nhere's \t\t the      command\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
      EmailCommand.parse_email_body(p).should eql "here's the command"
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


