require "spec_helper"

describe DependentUserMailer do
  it "should send invitation" do
    u = FactoryGirl.create :potential_user
    subject = "Please, join us"
    body = "It would be really nice"
    mail = DependentUserMailer.notify(u.id, subject, body)

    expect(mail.subject).to eql(subject)
    expect(mail.from).to eql(u.primary_user.name + " via Airbo")
    expect(mail.to).to eql([u.email])

    expect(mail.body).to match("You are invited to #{u.demo.name}")
    expect(mail.body).to match("It would be really nice")
    expect(mail.body).to have_selector("a[href *= 'invitations/#{u.invitation_code}']")
  end
end
