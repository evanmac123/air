require "spec_helper"

describe Mailer do
  describe '#activity_report' do

    #FIXME this test initally specified "EDT" as time zone and seem to convert
    # timestamp to 10am instead 1pm. 
    #
    # #NOTE investigate as part of general review of how the application is
    # using time zone

    let(:report) { Mailer.activity_report('fake csv data', 'Weird Demo-Name #3!', Time.parse("2011-05-01 13:00:00"), 'buddy@guy.com') }

    it 'should construct the correct name for the file attachment' do
      expect(report.attachments.first.filename).to eq("Weird_DemoName_3_2011_05_01_1300.csv")
    end

    it 'should construct an email with the correct parts' do
      report.deliver
      Mailer.should have_sent_email.from('play@ourairbo.com')
                                   .to('buddy@guy.com')
                                   .with_part('text/csv', 'fake csv data')
    end
  end
end
