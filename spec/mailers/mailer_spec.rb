require "spec_helper"

describe Mailer do
  subject { Mailer }

  describe "#activity_report" do
    before(:each) do
      Mailer.activity_report('fake csv data', 'Tiny Sparrow', Time.parse("2011-05-01 13:00:00 EDT"), 'vlad@example.com').deliver
    end
    
    it { should have_sent_email.to('vlad@example.com').with_subject('Activity dump for Tiny Sparrow as of May 01, 2011 at 01:00 PM Eastern').with_part('text/csv', 'fake csv data') }
  end
end
