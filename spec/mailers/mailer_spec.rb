require "spec_helper"

describe Mailer do
  describe '#activity_report' do
    let(:report) { Mailer.activity_report('fake csv data', 'Weird Demo-Name #3!', Time.parse("2011-05-01 13:00:00 EDT"), 'buddy@guy.com') }

    it 'should construct the correct name for the file attachment' do
      report.attachments['Weird_DemoName_3_2011_05_01_1300.csv'].should_not be_nil
      report.attachments['xxx'].should be_nil  # show above is not a false positive
    end

    it 'should construct an email with the correct parts' do
      report.deliver
      Mailer.should have_sent_email.from('play@ourairbo.com')
                                   .to('buddy@guy.com')
                                   .with_subject('Activity dump for Weird Demo-Name #3! as of May 01, 2011 at 01:00 PM Eastern')
                                   .with_part('text/csv', 'fake csv data')
    end
  end
end
