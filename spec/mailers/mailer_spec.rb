require "spec_helper"

describe Mailer do
  describe '#activity_report' do
    let(:report) { Mailer.activity_report('fake csv data', 'Weird Demo-Name #3!', Time.zone.parse("2011-05-01 13:00:00"), 'buddy@guy.com') }

    it 'should construct the correct name for the file attachment' do
      expect(report.attachments.first.filename).to eq("Weird_DemoName_3_2011_05_01_1300.csv")
    end

    it 'should construct an email with the correct parts' do
      mail = report.deliver

      expect(mail.from).to eq(['play@ourairbo.com'])
      expect(mail.to).to eq(['buddy@guy.com'])

      expect(mail.body.parts[1].to_s).to include("fake csv data")
    end
  end
end
