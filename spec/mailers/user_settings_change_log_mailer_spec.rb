require "spec_helper"

describe UserSettingsChangeLogMailer do
  it "should send confirmation for email" do
    uscl = FactoryBot.create :user_settings_change_log, email: "this@email.com"
    u = uscl.user
    mail = UserSettingsChangeLogMailer.change_email(uscl.id)

    expect(mail.subject).to eql("Email Change Confirmation")
    expect(mail.from).to eql(["support@ourairbo.com"])
    expect(mail.to).to eql([u.email])
    expect(mail.body).to include("Please click below to confirm the change.")

    expect(mail.body).to have_selector("a[href *= 'change_email?token=#{uscl.email_token}']")
  end
end
