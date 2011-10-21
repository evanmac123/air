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


def email_sent_in
 {  "to"=>"email_commands@hengage.net",
    "from"=>"kbedell@gmail.com",
    "subject"=>"I did something good!",
    "plain"=>"ate a banana \n\nhere is my message\nand this is a new line\n\n\nand two new lines\n\n\n\nand a third new line"
  }
end


