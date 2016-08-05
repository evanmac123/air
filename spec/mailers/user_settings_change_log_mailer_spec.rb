require "spec_helper"

describe UserSettingsChangeLogMailer do
  it "should send confirmation for email" do
    uscl = FactoryGirl.create :user_settings_change_log, email: "this@email.com"
    u = uscl.user
    mail = UserSettingsChangeLogMailer.change_email(uscl.id)

    expect(mail.subject).to eql("Email Change Confirmation")
    expect(mail.from).to eql(["support@ourairbo.com"])
    expect(mail.to).to eql([u.email])

    expect(mail.body).to include("It looks like you&#x27;ve changed your email address in Airbo")

    expect(mail.body).to have_selector("a[href *= 'change_email?token=#{uscl.email_token}']")
  end
end
